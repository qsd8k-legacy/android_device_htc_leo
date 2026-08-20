# android.hardware.light@2.0-service.htcleo

A HIDL `android.hardware.light@2.0` port of the legacy `liblights`
(`hardware/libhardware` `lights.c`) module for the HTC Leo, originally by
the CyanogenMod Project and marc1706.

## What changed vs. the legacy module

The old module was a `struct hw_module_t` shared library
(`lights.htcleo.so`) loaded via `libhardware`'s `hw_get_module()`. Since
Android O, that legacy interface is gone; devices instead run a standalone
binderized HIDL service that implements `ILight` and registers itself with
`hwservicemanager`. This directory is that service:

| Legacy (`lights.c`)             | HIDL port                                    |
|----------------------------------|-----------------------------------------------|
| `open_lights()` dispatch by name | `Light::mLights` map keyed by `Type`          |
| `set_light_backlight()`          | `Light::handleBacklight()`                    |
| `set_light_buttons()`            | `Light::handleButtons()`                      |
| `set_light_battery()`            | `Light::handleBattery()`                      |
| `set_light_notifications()`      | `Light::handleNotifications()`                |
| `set_light_attention()` (no-op)  | `Light::handleAttention()` (still a no-op)    |
| `pthread_mutex_t g_lock`         | `std::mutex mLock`                            |
| `t_battery_checker` pthread      | `std::thread mBatteryThread`                  |

All of the amber/green LED arbitration logic (`set_speaker_light_locked`,
`set_speaker_light_locked_dual`, `handle_speaker_battery_locked`,
`check_battery_level`) is carried over as-is, same sysfs nodes and same
LED color/blink decisions.

**One behavioral fix:** the legacy `check_battery_level()` never actually
parsed `/sys/class/power_supply/battery/status` (it round-tripped the
buffer through `sprintf(str, "%s", str)`, so `battery_state` always stayed
`0`), which meant the "is device charging" branch was dead code. The HIDL
version (`Light::checkBatteryLevel()`) parses the string for `"Charging"`
/ `"Full"` so charge-state LED switching actually works. Everything else
is a straight port.

## Files

- `Light.h` / `Light.cpp` — the `ILight` implementation.
- `service.cpp` — process entry point, registers the service as
  `android.hardware.light@2.0::ILight/default`.
- `Android.bp` — Soong build rule for `android.hardware.light@2.0-service.htcleo`.
- `android.hardware.light@2.0-service.htcleo.rc` — init script starting the service.
- `manifest.xml` — `<hal>` fragment to add to the device's vendor manifest.

## Integrating into a device tree

1. Copy this directory to `device/htc/leo/light` (or wherever your
   device tree keeps HAL sources) and remove the old
   `hardware/*/liblights` module (the `Android.mk` in the uploaded zip)
   from your build — it's superseded by this service.

2. Add the fragment from `manifest.xml` into your device's vendor
   manifest (the file pointed to by `DEVICE_MANIFEST_FILE` in
   `BoardConfig.mk`).

3. In `device.mk`, replace any old
   `PRODUCT_PACKAGES += lights.htcleo`
   with:

   ```
   PRODUCT_PACKAGES += android.hardware.light@2.0-service.htcleo
   ```

4. Make sure `android.hardware.light@2.0` is declared in your device's
   compatibility matrix / that the framework-side light HAL matrix entry
   is satisfied (this is standard on any AOSP tree with the light@2.0
   interface already checked out under
   `hardware/interfaces/light/2.0`).

5. Build and flash. Verify with:

   ```
   adb shell lshal | grep light
   ```

   which should show
   `android.hardware.light@2.0::ILight/default`, backed by
   `android.hardware.light@2.0-service.htcleo`.

## sysfs nodes expected on-device

- `/sys/class/leds/amber/brightness`, `/sys/class/leds/amber/blink`
- `/sys/class/leds/green/brightness`, `/sys/class/leds/green/blink`
- `/sys/class/leds/button-backlight/brightness`
- `/sys/class/leds/lcd-backlight/brightness`
- `/sys/class/power_supply/battery/status`

If your kernel exposes these under different node names, update the
string constants at the top of `Light.cpp`.

## License

Apache License, Version 2.0 — see `MODULE_LICENSE_APACHE2` / `NOTICE`
from the original `liblights` module; those terms carry over unchanged.
