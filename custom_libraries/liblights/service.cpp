/*
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

#include <android/hardware/light/2.0/ILight.h>
#include <hidl/HidlTransportSupport.h>
#include <log/log.h>

#include "Light.h"

using android::sp;
using android::status_t;
using android::OK;

using android::hardware::configureRpcThreadpool;
using android::hardware::joinRpcThreadpool;

using android::hardware::light::V2_0::ILight;
using android::hardware::light::V2_0::implementation::Light;

int main() {
    sp<ILight> light = new Light();

    configureRpcThreadpool(1, true /* callerWillJoin */);

    status_t status = light->registerAsService();
    if (status != OK) {
        ALOGE("Could not register ILight (%d)", status);
        return 1;
    }

    ALOGI("Light HAL service (HTC Leo) is ready.");
    joinRpcThreadpool();

    // Should not reach this point.
    return 1;
}
