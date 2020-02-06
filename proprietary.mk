# Copyright (C) 2013 The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This file is generated by device/htc/htcleo/setup-makefiles.sh from sportsst89 leo device tree

# Prebuilt libraries that are needed to build open-source libraries

# Adreno
PRODUCT_COPY_FILES += \
    device/htc/htcleo/proprietary/lib/egl/eglsubAndroid.so:system/lib/egl/eglsubAndroid.so \
    device/htc/htcleo/proprietary/lib/egl/libEGL_adreno200.so:system/lib/egl/libEGL_adreno200.so \
    device/htc/htcleo/proprietary/lib/egl/libGLESv1_CM_adreno200.so:system/lib/egl/libGLESv1_CM_adreno200.so \
    device/htc/htcleo/proprietary/lib/egl/libGLESv2_adreno200.so:system/lib/egl/libGLESv2_adreno200.so \
    device/htc/htcleo/proprietary/lib/egl/libplayback_adreno200.so:system/lib/egl/libplayback_adreno200.so \
    device/htc/htcleo/proprietary/lib/egl/libq3dtools_adreno200.so:system/lib/egl/libq3dtools_adreno200.so \
    device/htc/htcleo/proprietary/lib/libgsl.so:system/lib/libgsl.so \
    device/htc/htcleo/proprietary/lib/libOpenCL.so:system/lib/libOpenCL.so \
    device/htc/htcleo/proprietary/lib/libsc-a2xx.so:system/lib/libsc-a2xx.so \
    device/htc/htcleo/proprietary/etc/firmware/yamato_pfp.fw:system/etc/firmware/yamato_pfp.fw \
    device/htc/htcleo/proprietary/etc/firmware/yamato_pm4.fw:system/etc/firmware/yamato_pm4.fw \
    device/htc/htcleo/proprietary/vendor/lib/libRSDriver_adreno.so:system/vendor/lib/libRSDriver_adreno.so

# Audio
PRODUCT_COPY_FILES += \
    device/htc/htcleo/proprietary/etc/AdieHWCodecSetting.csv:system/etc/AdieHWCodecSetting.csv \
    device/htc/htcleo/proprietary/etc/AudioBTID.csv:system/etc/AudioBTID.csv \
    device/htc/htcleo/proprietary/lib/libhtc_acoustic.so:system/lib/libhtc_acoustic.so 

# Camera
#PRODUCT_COPY_FILES += \
#    device/htc/htcleo/proprietary/lib/libcamera.so:obj/lib/libcamera.so \
#    device/htc/htcleo/proprietary/lib/liboemcamera.so:system/lib/liboemcamera.so \
#    device/htc/htcleo/proprietary/lib/libcamera.so:system/lib/libcamera.so

# Compass
PRODUCT_COPY_FILES += \
    device/htc/htcleo/proprietary/bin/akmd:system/bin/akmd

# Firmware
PRODUCT_COPY_FILES += \
    device/htc/htcleo/proprietary/etc/firmware/bcm4329.hcd:system/etc/firmware/bcm4329.hcd \
    device/htc/htcleo/proprietary/etc/firmware/fw_bcmdhd.bin:system/vendor/firmware/fw_bcmdhd.bin \
    device/htc/htcleo/proprietary/etc/firmware/fw_bcmdhd_apsta.bin:system/vendor/firmware/fw_bcmdhd_apsta.bin \
    device/htc/htcleo/proprietary/etc/firmware/default.acdb:system/etc/firmware/default.acdb

# Radio log
PRODUCT_COPY_FILES += \
    device/htc/htcleo/proprietary/bin/parse_radio_log:system/bin/parse_radio_log 

# RIL
PRODUCT_COPY_FILES += \
    device/htc/htcleo/proprietary/lib/libhtc_ril.so:system/lib/libhtc_ril.so

# Omx
# PRODUCT_COPY_FILES += \
#    device/htc/htcleo/proprietary/lib/libOmxVdec.so:system/lib/libOmxVdec.so \
#    device/htc/htcleo/proprietary/lib/libOmxVidEnc.so:system/lib/libOmxVidEnc.so
