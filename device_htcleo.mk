# Copyright (C) 2009 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Overlay
DEVICE_PACKAGE_OVERLAYS += device/htc/htcleo/overlay

# Ramdisk
PRODUCT_COPY_FILES += \
	device/htc/htcleo/ramdisk/logo.rle:root/logo.rle \
	device/htc/htcleo/ramdisk/fstab.htcleo:root/fstab.htcleo \
	device/htc/htcleo/ramdisk/init.htcleo.rc:root/init.htcleo.rc \
	device/htc/htcleo/ramdisk/init.htcleo.power.rc:root/init.htcleo.power.rc \
	device/htc/htcleo/ramdisk/init.htcleo.usb.rc:root/init.htcleo.usb.rc \
	device/htc/htcleo/ramdisk/ueventd.htcleo.rc:root/ueventd.htcleo.rc

# GNSS HAL
PRODUCT_PACKAGES += \
    	android.hardware.gnss@1.0-impl

# GPS
PRODUCT_COPY_FILES += \
	device/htc/htcleo/configs/gps.conf:system/etc/gps.conf

PRODUCT_PACKAGES += \
	gps.htcleo \
	libgps \
	librpc

# HIDL
PRODUCT_COPY_FILES += \
    	device/htc/htcleo/manifest.xml:system/vendor/manifest.xml

# Keylayouts
PRODUCT_COPY_FILES += \
	device/htc/htcleo/keylayout/htcleo-keypad.kl:system/usr/keylayout/htcleo-keypad.kl \
	device/htc/htcleo/keylayout/htcleo-keypad.kcm:system/usr/keychars/htcleo-keypad.kcm \
	device/htc/htcleo/keylayout/h2w_headset.kl:system/usr/keylayout/h2w_headset.kl \
	device/htc/htcleo/keylayout/htcleo-touchscreen.idc:system/usr/idc/htcleo-touchscreen.idc


# Leo uses high-density artwork where available
PRODUCT_LOCALES += hdpi mdpi


# High Density art
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := hdpi

# Configs
PRODUCT_COPY_FILES += \
	device/htc/htcleo/configs/media_codecs.xml:system/etc/media_codecs.xml \
	device/htc/htcleo/configs/media_profiles.xml:system/etc/media_profiles.xml \
	device/htc/htcleo/configs/audio_policy.conf:system/etc/audio_policy.conf

# Media codecs
PRODUCT_COPY_FILES += \
	frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:system/etc/media_codecs_google_audio.xml \
	frameworks/av/media/libstagefright/data/media_codecs_google_telephony.xml:system/etc/media_codecs_google_telephony.xml \
	frameworks/av/media/libstagefright/data/media_codecs_google_video.xml:system/etc/media_codecs_google_video.xml

# Audio
# PRODUCT_PACKAGES += \
#     	android.hardware.audio@2.0-impl \
#     	android.hardware.audio.effect@2.0-impl \
#     	android.hardware.broadcastradio@1.0-impl \
#     	android.hardware.soundtrigger@2.0-impl \
# 	audio.usb.default \
# 	audio.a2dp.default \
# 	audio.primary.qsd8k

# Bluetooth
PRODUCT_PACKAGES += \
	android.hardware.bluetooth@1.0-impl

# Camera
#PRODUCT_PACKAGES += \
#	camera.qsd8k \
#	libshim_camera \
#	libshim_skia

# DRM
PRODUCT_PACKAGES += \
    	android.hardware.drm@1.0-impl

# Display
PRODUCT_PACKAGES += \
    	android.hardware.graphics.allocator@2.0-impl \
    	android.hardware.graphics.allocator@2.0-service \
    	android.hardware.graphics.composer@2.1-impl \
    	android.hardware.graphics.mapper@2.0-impl \
    	android.hardware.memtrack@1.0-impl \
	copybit.qsd8k \
	gralloc.qsd8k \
	hwcomposer.qsd8k \
	memtrack.qsd8k \
	libstlport

# Keymaster
PRODUCT_PACKAGES += \
    	android.hardware.keymaster@3.0-impl

# Lights
PRODUCT_PACKAGES += \
    	android.hardware.light@2.0-impl \
	lights.htcleo
# Omx
# PRODUCT_PACKAGES += \
#	libOmxCore \
#	libstagefrighthw

PRODUCT_PACKAGES += \
    	android.hardware.power@1.0-impl \
    	power.qsd8k

# Sensors
PRODUCT_PACKAGES += \
    	android.hardware.sensors@1.0-impl \
    	sensors.htcleo

# Vibrator
PRODUCT_PACKAGES += \
    	android.hardware.vibrator@1.0-impl

# Wifi
PRODUCT_PACKAGES += \
	android.hardware.wifi@1.0-service \
	libnetcmdiface \
	hostapd \
	libwpa_client \
	wpa_supplicant.conf \
	wpa_supplicant \
	wificond

PRODUCT_PACKAGES += \
	mkfs.f2fs \
	fsck.f2fs \
	make_f2fs \
	mkf2fsuserimg.sh

#PRODUCT_PACKAGES += \
#	Gello

# USB
PRODUCT_PACKAGES += \
    	android.hardware.usb@1.0-service.basic \

# Additional Propreties
PRODUCT_PROPERTY_OVERRIDES += \
	ro.sf.lcd_density=240 \
	rild.libpath=/system/lib/libhtc_ril.so \
	ro.ril.gprsclass=12 \
	ro.ril.hsdpa.category=8 \
	ro.ril.hsupa.category=5 \
	ro.ril.hsxpa=2 \
	ro.ril.def.agps.mode=2 \
	mobiledata.interfaces=rmnet0 \
	ro.media.dec.jpeg.memcap=20000000 \
	ro.opengles.version=131072 \
	ro.telephony.default_network=3 \
	ro.ril.enable.prl.recognition=1 \
	ro.ril.enable.managed.roaming=1 \
	ro.ril.oem.nosim.ecclist=911,112,999,000,08,118,120,122,110,119,995 \
	ro.ril.emc.mode=2 \
	ro.telephony.ril.config=signalstrengthgsm,apptypesim,datacallapn \
	persist.sys.usb.config=mtp,adb \
	persist.sys.root_access=1 \
	persist.sys.purgeable_assets=1 \
	config.disable_atlas=true \
	windowsmgr.max_events_per_sec=120 \
	ro.serialno=0123456789ABCDEF \
	debug.sf.hw=1 \
	debug.sf.no_hw_vsync=1 \
	debug.composition.type=mdp \
	ro.zygote.disable_gl_preload=true \
	camera2.portability.force_api=1 \
	debug.gr.numframebuffers=2 \
	ro.setupwizard.enable_bypass=1 \
	persist.sys.silent=1 \
	ro.config.max_starting_bg=8 \
	ro.sys.fw.bg_apps_limit=16 \
	ro.config.low_ram=true \
	persist.sys.force_highendgfx=true \
	audio.offload.disable=1 \
	ro.sys.fw.dex2oat_thread_count=1 \
	power.saving.mode=1 \
	ro.vold.primary_physical=1 \
	persist.graphics.vulkan.disable=true \
	ro.config.low_ram=true \

# This is needed for the usb workaround
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    sys.usb.ffs.aio_compat=1

# Default heap settings for 512mb device
include frameworks/native/build/phone-hdpi-512-dalvik-heap.mk

# Properties
PRODUCT_PROPERTY_OVERRIDES += \
	debug.camcorder.disablemeta=1 \
	rw.media.record.hasb=0

#Art
PRODUCT_PROPERTY_OVERRIDES += \
	dalvik.vm.dex2oat-filter=balanced \
	dalvik.vm.dex2oat-swap=false \
	dalvik.vm.image-dex2oat-filter=speed

# Properties
PRODUCT_PROPERTY_OVERRIDES += \
	wifi.interface=wlan0

# Set usb type
#ADDITIONAL_DEFAULT_PROPERTIES += \
#	persist.service.adb.enable=1 \
#	ro.adb.secure=0 \
#	ro.secure=0 \
#	ro.allow.mock.location=1

# Permissions
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/handheld_core_hardware.xml:system/etc/permissions/handheld_core_hardware.xml \
	frameworks/native/data/etc/android.hardware.telephony.gsm.xml:system/etc/permissions/android.hardware.telephony.gsm.xml \
	frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:system/etc/permissions/android.hardware.camera.flash-autofocus.xml \
	frameworks/native/data/etc/android.hardware.location.gps.xml:system/etc/permissions/android.hardware.location.gps.xml \
	frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
	frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:system/etc/permissions/android.hardware.sensor.accelerometer.xml \
	frameworks/native/data/etc/android.hardware.sensor.compass.xml:system/etc/permissions/android.hardware.sensor.compass.xml \
	frameworks/native/data/etc/android.hardware.sensor.proximity.xml:system/etc/permissions/android.hardware.sensor.proximity.xml \
	frameworks/native/data/etc/android.hardware.sensor.light.xml:system/etc/permissions/android.hardware.sensor.light.xml \
	frameworks/native/data/etc/android.hardware.touchscreen.multitouch.distinct.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.distict.xml \
	frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml \
	frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml \
	frameworks/native/data/etc/android.hardware.bluetooth.xml:system/etc/permissions/android.hardware.bluetooth.xml \

# RenderScript HAL
PRODUCT_PACKAGES += \
    android.hardware.renderscript@1.0-impl

# 512MB specific properties.

# lmkd can kill more now.
PRODUCT_PROPERTY_OVERRIDES += \
     ro.lmk.medium=700 \

# madvise random in ART to reduce page cache thrashing.
PRODUCT_PROPERTY_OVERRIDES += \
dalvik.vm.madvise-random=true

# Speed services and wifi-service for better performance.
#PRODUCT_SYSTEM_SERVER_COMPILER_FILTER := speed

PRODUCT_PROPERTY_OVERRIDES += \
     pm.dexopt.shared=speed

# Proprietary
$(call inherit-product, device/htc/htcleo/proprietary.mk)
