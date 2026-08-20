/*
 * Copyright (C) 2008 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <hardware/sensors.h>
#include <fcntl.h>
#include <errno.h>
#include <dirent.h>
#include <math.h>

#include <poll.h>
#include <pthread.h>

#include <linux/input.h>

#include <cutils/atomic.h>
#include <cutils/log.h>
#include <cstring>
#include <deque>

#include "nusensors.h"
#include "LightSensor.h"
#include "ProximitySensor.h"
#include "AkmSensor.h"

/*****************************************************************************/

struct sensors_poll_context_t {
    struct sensors_poll_device_1 device; // must be first, note the _1

    sensors_poll_context_t();
    ~sensors_poll_context_t();
    int activate(int handle, int enabled);
    int setDelay(int handle, int64_t ns);
    int pollEvents(sensors_event_t* data, int count);
    int batch(int handle, int flags, int64_t period_ns, int64_t timeout);
    int flush(int handle);

private:
    enum {
        light           = 0,
        proximity       = 1,
        akm             = 2,
        numSensorDrivers,
        numFds,
    };

    static const size_t wake = numFds - 1;
    static const char WAKE_MESSAGE = 'W';
    struct pollfd mPollFds[numFds];
    int mWritePipeFd;
    SensorBase* mSensors[numSensorDrivers];

    // flush() runs on a binder thread and can be called concurrently with
    // pollEvents() running on the poll thread, so the synthetic
    // META_DATA_FLUSH_COMPLETE events it queues need their own lock.
    pthread_mutex_t mFlushQueueLock;
    std::deque<sensors_event_t> mFlushQueue;

    int handleToDriver(int handle) const {
        switch (handle) {
            case ID_A:
            case ID_M:
            case ID_O:
                return akm;
            case ID_P:
                return proximity;
            case ID_L:
                return light;
        }
        return -EINVAL;
    }
};

/*****************************************************************************/

sensors_poll_context_t::sensors_poll_context_t()
{
    pthread_mutex_init(&mFlushQueueLock, NULL);

    mSensors[light] = new LightSensor();
    mPollFds[light].fd = mSensors[light]->getFd();
    mPollFds[light].events = POLLIN;
    mPollFds[light].revents = 0;

    mSensors[proximity] = new ProximitySensor();
    mPollFds[proximity].fd = mSensors[proximity]->getFd();
    mPollFds[proximity].events = POLLIN;
    mPollFds[proximity].revents = 0;

    mSensors[akm] = new AkmSensor();
    mPollFds[akm].fd = mSensors[akm]->getFd();
    mPollFds[akm].events = POLLIN;
    mPollFds[akm].revents = 0;

    int wakeFds[2];
    int result = pipe(wakeFds);
    ALOGE_IF(result<0, "error creating wake pipe (%s)", strerror(errno));
    fcntl(wakeFds[0], F_SETFL, O_NONBLOCK);
    fcntl(wakeFds[1], F_SETFL, O_NONBLOCK);
    mWritePipeFd = wakeFds[1];

    mPollFds[wake].fd = wakeFds[0];
    mPollFds[wake].events = POLLIN;
    mPollFds[wake].revents = 0;
}

sensors_poll_context_t::~sensors_poll_context_t() {
    for (int i=0 ; i<numSensorDrivers ; i++) {
        delete mSensors[i];
    }
    close(mPollFds[wake].fd);
    close(mWritePipeFd);
    pthread_mutex_destroy(&mFlushQueueLock);
}

int sensors_poll_context_t::activate(int handle, int enabled) {
    int index = handleToDriver(handle);
    if (index < 0) return index;
    int err =  mSensors[index]->setEnable(handle, enabled);
    if (enabled && !err) {
        const char wakeMessage(WAKE_MESSAGE);
        int result = write(mWritePipeFd, &wakeMessage, 1);
        ALOGE_IF(result<0, "error sending wake message (%s)", strerror(errno));
    }
    return err;
}

int sensors_poll_context_t::setDelay(int handle, int64_t ns) {

    int index = handleToDriver(handle);
    if (index < 0) return index;
    return mSensors[index]->setDelay(handle, ns);
}

// None of this hardware generation's drivers (BMA150/AK8973/CM3602, all
// input-device-backed) have an on-chip FIFO, which is why every entry in
// sSensorList advertises fifoMaxEventCount = 0. That already tells clients
// not to expect real batching, so `timeout` here is advisory, not a
// contract we can violate: we cannot buffer/delay events in hardware, but
// we are not required to refuse the request either. Silently delivering
// events immediately (timeout effectively 0) is the honest fallback for
// "no FIFO" - returning an error instead crashes SensorService on some
// framework builds (the HIDL 1.0 passthrough wrapper does not tolerate a
// failed batch() call and kills sensorservice rather than degrading).
int sensors_poll_context_t::batch(int handle, int flags,
        int64_t period_ns, int64_t timeout)
{
    int index = handleToDriver(handle);
    if (index < 0) return index;

    if (period_ns < 0) {
        return -EINVAL;
    }
    if (timeout != 0) {
        ALOGW("batch: no hardware FIFO on this device, ignoring requested "
              "max report latency (handle=%d timeout=%lld); events will "
              "be delivered as sampled instead of batched",
              handle, (long long)timeout);
    }
    return mSensors[index]->setDelay(handle, period_ns);
}

int sensors_poll_context_t::flush(int handle)
{
    int index = handleToDriver(handle);
    if (index < 0) return index;

    // Per the HAL 1.1+ contract: flush() on an inactive sensor must fail
    // with -EINVAL rather than silently posting a completion event.
    if (!mSensors[index]->isEnabled(handle)) {
        return -EINVAL;
    }

    sensors_event_t ev;
    memset(&ev, 0, sizeof(ev));
    ev.version = META_DATA_VERSION;
    ev.sensor = 0;
    ev.type = SENSOR_TYPE_META_DATA;
    ev.meta_data.what = META_DATA_FLUSH_COMPLETE;
    ev.meta_data.sensor = handle;
    ev.timestamp = SensorBase::getTimestamp();

    pthread_mutex_lock(&mFlushQueueLock);
    mFlushQueue.push_back(ev);
    pthread_mutex_unlock(&mFlushQueueLock);

    // wake the poll thread so pollEvents() drains the queue promptly
    // instead of waiting for the next real hardware event
    const char wakeMessage(WAKE_MESSAGE);
    int result = write(mWritePipeFd, &wakeMessage, 1);
    ALOGE_IF(result<0, "flush: error sending wake message (%s)", strerror(errno));

    return 0;
}

int sensors_poll_context_t::pollEvents(sensors_event_t* data, int count)
{
    int nbEvents = 0;
    int n = 0;

    // deliver any pending META_DATA_FLUSH_COMPLETE events queued by
    // flush() before anything else, same as the real drivers' backlog
    pthread_mutex_lock(&mFlushQueueLock);
    while (count && !mFlushQueue.empty()) {
        *data++ = mFlushQueue.front();
        mFlushQueue.pop_front();
        count--;
        nbEvents++;
    }
    pthread_mutex_unlock(&mFlushQueueLock);
    if (nbEvents && !count) {
        return nbEvents;
    }

    do {
        // see if we have some leftover from the last poll()
        for (int i=0 ; count && i<numSensorDrivers ; i++) {
            SensorBase* const sensor(mSensors[i]);
            if ((mPollFds[i].revents & POLLIN) || (sensor->hasPendingEvents())) {
                int nb = sensor->readEvents(data, count);
                if (nb < count) {
                    // no more data for this sensor
                    mPollFds[i].revents = 0;
                }
                count -= nb;
                nbEvents += nb;
                data += nb;
            }
        }

        if (count) {
            // we still have some room, so try to see if we can get
            // some events immediately or just wait if we don't have
            // anything to return
            do {
                n = poll(mPollFds, numFds, nbEvents ? 0 : -1);
            } while (n < 0 && errno == EINTR);
            // EINTR is routine (signal delivery, process attach, etc.) and
            // recoverable - retry rather than surface it as a HAL failure.
            // SensorService treats any nonzero return from poll() as fatal
            // and aborts its own thread on it, so this is not optional.
            if (n<0) {
                ALOGE("poll() failed (%s)", strerror(errno));
                return -errno;
            }
            if (mPollFds[wake].revents & POLLIN) {
                char msg;
                int result = read(mPollFds[wake].fd, &msg, 1);
                ALOGE_IF(result<0, "error reading from wake pipe (%s)", strerror(errno));
                ALOGE_IF(msg != WAKE_MESSAGE, "unknown message on wake queue (0x%02x)", int(msg));
                mPollFds[wake].revents = 0;
            }
        }
        // if we have events and space, go read them
    } while (n && count);

    return nbEvents;
}

/*****************************************************************************/

static int poll__close(struct hw_device_t *dev)
{
    sensors_poll_context_t *ctx = (sensors_poll_context_t *)dev;
    if (ctx) {
        delete ctx;
    }
    return 0;
}

static int poll__activate(struct sensors_poll_device_t *dev,
        int handle, int enabled) {
    sensors_poll_context_t *ctx = (sensors_poll_context_t *)dev;
    return ctx->activate(handle, enabled);
}

static int poll__setDelay(struct sensors_poll_device_t *dev,
        int handle, int64_t ns) {
    sensors_poll_context_t *ctx = (sensors_poll_context_t *)dev;
    return ctx->setDelay(handle, ns);
}

static int poll__poll(struct sensors_poll_device_t *dev,
        sensors_event_t* data, int count) {
    sensors_poll_context_t *ctx = (sensors_poll_context_t *)dev;
    return ctx->pollEvents(data, count);
}

static int poll__batch(struct sensors_poll_device_1 *dev,
        int handle, int flags, int64_t period_ns, int64_t timeout) {
    sensors_poll_context_t *ctx = (sensors_poll_context_t *)dev;
    return ctx->batch(handle, flags, period_ns, timeout);
}

static int poll__flush(struct sensors_poll_device_1 *dev, int handle) {
    sensors_poll_context_t *ctx = (sensors_poll_context_t *)dev;
    return ctx->flush(handle);
}

/*****************************************************************************/

int init_nusensors(hw_module_t const* module, hw_device_t** device)
{
    int status = -EINVAL;

    sensors_poll_context_t *dev = new sensors_poll_context_t();
    memset(&dev->device, 0, sizeof(sensors_poll_device_1_t));

    dev->device.common.tag      = HARDWARE_DEVICE_TAG;
    dev->device.common.version  = SENSORS_DEVICE_API_VERSION_1_3;
    dev->device.common.module   = const_cast<hw_module_t*>(module);
    dev->device.common.close    = poll__close;
    dev->device.activate        = poll__activate;
    dev->device.setDelay        = poll__setDelay;
    dev->device.poll            = poll__poll;
    dev->device.batch           = poll__batch;
    dev->device.flush           = poll__flush;

    *device = &dev->device.common;
    status = 0;
    return status;
}
