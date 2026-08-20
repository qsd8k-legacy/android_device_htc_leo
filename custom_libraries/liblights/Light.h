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
 *
 * HIDL (android.hardware.light@2.0) port of the legacy HTC Leo
 * liblights (hardware/libhardware lights.c) module.
 */

#ifndef ANDROID_HARDWARE_LIGHT_V2_0_LIGHT_H
#define ANDROID_HARDWARE_LIGHT_V2_0_LIGHT_H

#include <android/hardware/light/2.0/ILight.h>
#include <hidl/Status.h>

#include <atomic>
#include <map>
#include <mutex>
#include <thread>

namespace android {
namespace hardware {
namespace light {
namespace V2_0 {
namespace implementation {

using ::android::hardware::hidl_vec;
using ::android::hardware::Return;
using ::android::hardware::light::V2_0::ILight;
using ::android::hardware::light::V2_0::LightState;
using ::android::hardware::light::V2_0::Status;
using ::android::hardware::light::V2_0::Type;

class Light : public ILight {
  public:
    Light();

    // Methods from ::android::hardware::light::V2_0::ILight follow.
    Return<Status> setLight(Type type, const LightState& state) override;
    Return<void> getSupportedTypes(getSupportedTypes_cb _hidl_cb) override;

  private:
    // sysfs-backed handlers, one per supported light Type.
    void handleBacklight(const LightState& state);
    void handleButtons(const LightState& state);
    void handleBattery(const LightState& state);
    void handleNotifications(const LightState& state);
    void handleAttention(const LightState& state);

    // Ported logic from the legacy driver.
    void setSpeakerLightLocked(const LightState& state);
    void setSpeakerLightLockedDual(const LightState& bstate, const LightState& nstate);
    void handleSpeakerBatteryLocked();
    int checkBatteryLevel(int chargingHint);
    void startBatteryThread();
    void batteryThreadLoop();

    static bool isLit(const LightState& state);
    static int rgbToBrightness(const LightState& state);
    static int writeInt(const char* path, int value);

    std::map<Type, std::function<void(const LightState&)>> mLights;

    std::mutex mLock;
    LightState mNotification{};
    LightState mBattery{};

    std::thread mBatteryThread;
    std::atomic<bool> mBatteryThreadRunning{false};
    std::atomic<bool> mBatteryThreadCheck{false};

    int mLastBatteryState = 0;
    int mForceLedAmber = 0;
};

}  // namespace implementation
}  // namespace V2_0
}  // namespace light
}  // namespace hardware
}  // namespace android

#endif  // ANDROID_HARDWARE_LIGHT_V2_0_LIGHT_H
