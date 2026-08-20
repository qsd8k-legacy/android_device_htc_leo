/*
 * Copyright (C) 2011 The CyanogenMod Project
 * Copyright (C) 2012 marc1706
 * Copyright (C) 2017 The LineageOS Project
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

#define LOG_TAG "android.hardware.light@2.0-service.htcleo"

#include <log/log.h>

#include <cerrno>
#include <cstdio>
#include <cstring>
#include <fcntl.h>
#include <unistd.h>

#include "Light.h"

namespace android {
namespace hardware {
namespace light {
namespace V2_0 {
namespace implementation {

// battery state checker values (kept from the original driver)
namespace {
constexpr int BATT_NONE = 1;
constexpr int BATT_FULL = 5;
constexpr int BATT_CHARGING = 9;

enum LedColor {
    LED_AMBER,
    LED_GREEN,
    LED_BLUE,
    LED_BLANK,
};

// sysfs nodes
const char* const AMBER_LED_FILE = "/sys/class/leds/amber/brightness";
const char* const GREEN_LED_FILE = "/sys/class/leds/green/brightness";

const char* const BUTTON_FILE = "/sys/class/leds/button-backlight/brightness";

const char* const AMBER_BLINK_FILE = "/sys/class/leds/amber/blink";
const char* const GREEN_BLINK_FILE = "/sys/class/leds/green/blink";

const char* const LCD_BACKLIGHT_FILE = "/sys/class/leds/lcd-backlight/brightness";

const char* const BATTERY_STATUS_FILE = "/sys/class/power_supply/battery/status";
}  // namespace

int Light::writeInt(const char* path, int value) {
    int fd = open(path, O_RDWR);
    if (fd < 0) {
        ALOGE("write_int failed to open %s: %s", path, strerror(errno));
        return -errno;
    }

    char buffer[20];
    int bytes = snprintf(buffer, sizeof(buffer), "%d\n", value);
    int written = write(fd, buffer, bytes);
    close(fd);

    return written == -1 ? -errno : 0;
}

bool Light::isLit(const LightState& state) {
    return (state.color & 0x00ffffff) != 0;
}

int Light::rgbToBrightness(const LightState& state) {
    int color = state.color & 0x00ffffff;
    return ((77 * ((color >> 16) & 0x00ff)) + (150 * ((color >> 8) & 0x00ff)) +
            (29 * (color & 0x00ff))) >>
           8;
}

Light::Light() {
    mLights.emplace(Type::BACKLIGHT, [this](const LightState& state) { handleBacklight(state); });
    mLights.emplace(Type::BUTTONS, [this](const LightState& state) { handleButtons(state); });
    mLights.emplace(Type::BATTERY, [this](const LightState& state) { handleBattery(state); });
    mLights.emplace(Type::NOTIFICATIONS,
                     [this](const LightState& state) { handleNotifications(state); });
    mLights.emplace(Type::ATTENTION, [this](const LightState& state) { handleAttention(state); });
}

/*
 * Drive the shared amber/green speaker (notification) LED.
 * Ported from set_speaker_light_locked() in the legacy driver.
 */
void Light::setSpeakerLightLocked(const LightState& state) {
    unsigned int colorRGB = state.color & 0xFFFFFF;
    int color = LED_BLANK;

    if (colorRGB & 0xFF) color = LED_BLUE;
    if ((colorRGB >> 8) & 0xFF) color = LED_GREEN;
    if ((colorRGB >> 16) & 0xFF) color = LED_AMBER;

    // Avoid showing the green LED first while the battery is between
    // 90% and 100% -- carried over from marc1706's original fix.
    if (state.flashMode == Flash::NONE && color == LED_GREEN && mForceLedAmber) {
        color = LED_AMBER;
        mForceLedAmber = 0;
    }

    switch (state.flashMode) {
        case Flash::TIMED:
        case Flash::HARDWARE:
            switch (color) {
                case LED_AMBER:
                    writeInt(AMBER_BLINK_FILE, 2);
                    writeInt(GREEN_LED_FILE, 0);
                    break;
                case LED_GREEN:
                case LED_BLUE:
                    writeInt(GREEN_BLINK_FILE, 3);
                    writeInt(AMBER_LED_FILE, 0);
                    break;
                case LED_BLANK:
                    writeInt(AMBER_BLINK_FILE, 0);
                    writeInt(GREEN_BLINK_FILE, 0);
                    break;
                default:
                    ALOGE("%s: colorRGB=%08X, unknown color", __func__, colorRGB);
                    break;
            }
            break;
        case Flash::NONE:
            switch (color) {
                case LED_AMBER:
                    writeInt(AMBER_LED_FILE, 1);
                    writeInt(GREEN_LED_FILE, 0);
                    break;
                case LED_GREEN:
                case LED_BLUE:
                    writeInt(AMBER_LED_FILE, 0);
                    writeInt(GREEN_LED_FILE, 1);
                    break;
                case LED_BLANK:
                    writeInt(AMBER_LED_FILE, 0);
                    writeInt(GREEN_LED_FILE, 0);
                    break;
                default:
                    break;
            }
            break;
        default:
            ALOGE("%s: colorRGB=%08X, unknown mode %d", __func__, colorRGB,
                  static_cast<int>(state.flashMode));
    }
}

/*
 * Check the battery charge status and drive the LED accordingly.
 * Ported from check_battery_level(); the original code never actually
 * parsed BATTERY_STATUS_FILE ("Charging"/"Full"/"Discharging") into
 * the BATT_* constants (it round-tripped the buffer through sprintf),
 * so charge-state detection was effectively dead. That's fixed here
 * so the amber/green switching this function drives actually works.
 *
 * @param chargingHint: caller's hint of whether we're charging, used
 *                       for the dual (battery + notification) LED case.
 * returns: 1 if charging, 0 otherwise.
 */
int Light::checkBatteryLevel(int chargingHint) {
    char str[32] = {0};
    int battery_state = BATT_NONE;

    int batt = open(BATTERY_STATUS_FILE, O_RDONLY);
    if (batt >= 0) {
        ssize_t n = read(batt, str, sizeof(str) - 1);
        close(batt);
        if (n > 0) {
            str[n] = '\0';
            if (strstr(str, "Charging") != nullptr) {
                battery_state = BATT_CHARGING;
            } else if (strstr(str, "Full") != nullptr) {
                battery_state = BATT_FULL;
            } else {
                battery_state = BATT_NONE;
            }
        }
    } else {
        ALOGE("%s: failed to open %s: %s", __func__, BATTERY_STATUS_FILE, strerror(errno));
    }

    if (mLastBatteryState != BATT_CHARGING && mLastBatteryState != BATT_FULL) {
        mLastBatteryState = BATT_NONE;
    }

    // did the battery state change?
    if (battery_state != mLastBatteryState) {
        mLastBatteryState = battery_state;

        if (isLit(mBattery) && isLit(mNotification)) {
            if (battery_state == BATT_CHARGING) {
                // fast blink amber
                writeInt(AMBER_BLINK_FILE, 2);
                writeInt(GREEN_LED_FILE, 0);
                if (chargingHint) chargingHint = 1;
            } else {
                // fast blink green
                writeInt(AMBER_LED_FILE, 0);
                writeInt(GREEN_BLINK_FILE, 3);
                mBatteryThreadCheck = false;
                if (chargingHint) chargingHint = 1;
            }
        } else if (!(isLit(mBattery) && isLit(mNotification))) {
            if (battery_state == BATT_CHARGING) {
                writeInt(AMBER_LED_FILE, 1);
                writeInt(GREEN_LED_FILE, 0);
                if (chargingHint) chargingHint = 1;
            } else if (battery_state == BATT_FULL) {
                writeInt(AMBER_LED_FILE, 0);
                writeInt(GREEN_LED_FILE, 1);
                mBatteryThreadCheck = false;
                if (chargingHint) chargingHint = 0;
            }
        }
        ALOGV("%s: state=%u", __func__, battery_state);
    } else if (chargingHint) {
        chargingHint = (battery_state == BATT_CHARGING) ? 1 : 0;
    }

    return chargingHint;
}

/*
 * Ported from battery_level_check() / start_battery_thread().
 * Polls BATTERY_STATUS_FILE every 5s while a charge/notification
 * conflict is being resolved.
 */
void Light::batteryThreadLoop() {
    while (mBatteryThreadRunning.exchange(true)) {
        // wait for a previous thread instance to finish
        usleep(500 * 1000);
    }

    mBatteryThreadCheck = true;

    while (mBatteryThreadCheck) {
        {
            std::lock_guard<std::mutex> lock(mLock);
            checkBatteryLevel(0);
        }
        sleep(5);
    }

    ALOGV("%s: done with thread", __func__);
    mBatteryThreadRunning = false;
}

void Light::startBatteryThread() {
    if (mBatteryThread.joinable()) {
        mBatteryThread.detach();
    }
    mBatteryThread = std::thread(&Light::batteryThreadLoop, this);
}

/*
 * Ported from set_speaker_light_locked_dual(): both the battery and
 * notification LED states are lit at once, so pick one shared color.
 */
void Light::setSpeakerLightLockedDual(const LightState& bstate, const LightState& /*nstate*/) {
    unsigned int bcolorRGB = bstate.color & 0xFFFFFF;
    int bcolor = LED_BLANK;
    int isCharging = checkBatteryLevel(1);

    if ((bcolorRGB >> 8) & 0xFF) bcolor = LED_GREEN;
    if ((bcolorRGB >> 16) & 0xFF) bcolor = LED_AMBER;

    if (bcolor == LED_GREEN && isCharging) {
        writeInt(AMBER_BLINK_FILE, 2);
        writeInt(GREEN_LED_FILE, 0);
        startBatteryThread();
    } else if (bcolor == LED_AMBER) {
        writeInt(AMBER_BLINK_FILE, 2);
        writeInt(GREEN_LED_FILE, 0);
    } else if (bcolor == LED_GREEN) {
        writeInt(AMBER_LED_FILE, 0);
        writeInt(GREEN_BLINK_FILE, 3);
    } else {
        ALOGE("%s: unexpected color: bcolorRGB=%08x", __func__, bcolorRGB);
    }
}

/*
 * Ported from handle_speaker_battery_locked(): arbitrates between the
 * battery and notification LED states, since they share one physical LED.
 */
void Light::handleSpeakerBatteryLocked() {
    unsigned int colorRGB = mBattery.color & 0xFFFFFF;
    int ret = 0;

    // stop any running battery poll thread; it'll be restarted if needed
    mBatteryThreadCheck = false;

    if (isLit(mBattery) && isLit(mNotification)) {
        setSpeakerLightLockedDual(mBattery, mNotification);
    } else if (isLit(mBattery)) {
        // battery is below 100% and trying to show green -> force amber
        if ((colorRGB >> 8) & 0xFF) {
            ret = checkBatteryLevel(1);
            if (ret) {
                mForceLedAmber = 1;
                startBatteryThread();
            }
            ALOGV("%s: changing color from LED_GREEN to LED_AMBER", __func__);
        }
        setSpeakerLightLocked(mBattery);
    } else {
        setSpeakerLightLocked(mNotification);
    }
    ALOGV("%s: battery=%d, notification=%d", __func__, isLit(mBattery), isLit(mNotification));
}

void Light::handleBacklight(const LightState& state) {
    std::lock_guard<std::mutex> lock(mLock);
    int brightness = rgbToBrightness(state);
    ALOGV("%s: brightness=%d color=0x%08x", __func__, brightness, state.color);
    writeInt(LCD_BACKLIGHT_FILE, brightness);
}

void Light::handleButtons(const LightState& state) {
    std::lock_guard<std::mutex> lock(mLock);
    writeInt(BUTTON_FILE, isLit(state) ? 255 : 0);
}

void Light::handleBattery(const LightState& state) {
    std::lock_guard<std::mutex> lock(mLock);
    mBattery = state;
    handleSpeakerBatteryLocked();
}

void Light::handleNotifications(const LightState& state) {
    std::lock_guard<std::mutex> lock(mLock);
    mNotification = state;
    handleSpeakerBatteryLocked();
}

void Light::handleAttention(const LightState& /*state*/) {
    // HTC Leo has no dedicated attention light, matching the legacy driver.
}

Return<Status> Light::setLight(Type type, const LightState& state) {
    auto it = mLights.find(type);

    if (it == mLights.end()) {
        return Status::LIGHT_NOT_SUPPORTED;
    }

    it->second(state);

    return Status::SUCCESS;
}

Return<void> Light::getSupportedTypes(getSupportedTypes_cb _hidl_cb) {
    std::vector<Type> types;
    for (auto const& light : mLights) {
        types.push_back(light.first);
    }

    _hidl_cb(types);

    return Void();
}

}  // namespace implementation
}  // namespace V2_0
}  // namespace light
}  // namespace hardware
}  // namespace android
