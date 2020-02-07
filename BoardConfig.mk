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
#
# This file sets variables that control the way modules are built
# thorughout the system. It should not be used to conditionally
# disable makefiles (the proper mechanism to control what gets
# included in a build is to use PRODUCT_PACKAGES in a product
# definition file).
#

# WARNING: This line must come *before* including the proprietary
# variant, so that it gets overwritten by the parent (which goes
# against the traditional rules of inheritance).

# general
USE_CAMERA_STUB := false

TARGET_SPECIFIC_HEADER_PATH := device/htc/htcleo/include

# Board/CPU
TARGET_NO_BOOTLOADER := true
BOARD_VENDOR := htc
TARGET_BOOTLOADER_BOARD_NAME := htcleo
TARGET_BOARD_PLATFORM := qsd8k
TARGET_BOARD_PLATFORM_GPU := qcom-adreno200
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_VARIANT := generic
ARCH_ARM_HAVE_TLS_REGISTER := true
TARGET_NEEDS_NON_PIE_SUPPORT := true
TARGET_DISABLE_ARM_PIE := true
USE_CLANG_PLATFORM_BUILD := true
TARGET_NEEDS_TEXT_RELOCATIONS := true

# Kernel
TARGET_KERNEL_SOURCE := kernel/htc/htcleo
TARGET_KERNEL_CONFIG := htcleo_defconfig
BOARD_KERNEL_CMDLINE := androidboot.selinux=permissive
BOARD_KERNEL_BASE := 0x11800000
TARGET_KERNEL_CROSS_COMPILE_PREFIX := arm-linux-androideabi-
BOARD_KERNEL_IMAGE_NAME := zImage
TARGET_ALLOWS_INVALID_PTHREAD := true

# Audio
BOARD_USES_GENERIC_AUDIO := true
TARGET_USES_QCOM_MM_AUDIO := true

# Bluetooth
BOARD_HAVE_BLUETOOTH := true
BOARD_HAVE_BLUETOOTH_BCM := true
BOARD_BLUETOOTH_USES_HCIATTACH_PROPERTY := false
BOARD_CUSTOM_BT_CONFIG := device/htc/htcleo/bluetooth//vnd_htcleo.txt
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/htc/htcleo/bluetooth/include

# Display
BOARD_EGL_CFG := device/htc/htcleo/configs/egl.cfg
BOARD_ADRENO_DECIDE_TEXTURE_TARGET := true
TARGET_DISABLE_TRIPLE_BUFFERING := true
BOARD_NEEDS_MEMORYHEAPPMEM := true
BOARD_EGL_WORKAROUND_BUG_10194508 := true
TARGET_NO_HW_VSYNC := true
BOARD_GLOBAL_CFLAGS += -DTARGET_8x50
TARGET_FORCE_SCREENSHOT_CPU_PATH := true
TARGET_USES_ION := true

#Bootanimation
TARGET_BOOTANIMATION_PRELOAD := true
TARGET_BOOTANIMATION_TEXTURE_CACHE := true
TARGET_BOOTANIMATION_USE_RGB565 := true
TARGET_BOOTANIMATION_HALF_RES := true

# Camera/Media
TARGET_USES_SUBMIT_ONE_INPUT_BUFFER := true
TARGET_NEEDS_PRELINK_SUPPORT := true
BOARD_USES_QCOM_HARDWARE := true
BOARD_USES_PMEM_ADSP := true
BOARD_NUMBER_OF_CAMERAS := 1
TARGET_RELEASE_CPPFLAGS += -DNEEDS_VECTORIMPL_SYMBOLS
BOARD_GLOBAL_CFLAGS += -DQCOM_NO_SECURE_PLAYBACK
BOARD_USES_MDP31 := true

# Wifi bcmdhd config
WIFI_BAND := 802_11_ABG
WPA_SUPPLICANT_VERSION := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_bcmdhd
BOARD_HOSTAPD_DRIVER := NL80211
BOARD_HOSTAPD_PRIVATE_LIB := lib_driver_cmd_bcmdhd
BOARD_WLAN_DEVICE := bcmdhd
WIFI_DRIVER_FW_PATH_STA := "/system/vendor/firmware/fw_bcmdhd.bin"
WIFI_DRIVER_FW_PATH_AP := "/system/vendor/firmware/fw_bcmdhd_apsta.bin"
WIFI_DRIVER_FW_PATH_PARAM := "/sys/module/bcmdhd/parameters/firmware_path"
WIFI_DRIVER_MODULE_NAME := bcmdhd

# Compass/Accelerometer
BOARD_VENDOR_USE_AKMD := akm8973

# GPS
BOARD_USES_GPSSHIM := true
BOARD_GPS_LIBRARIES := libgps

# ART
ifeq ($(HOST_OS),linux)
  ifeq ($(TARGET_BUILD_VARIANT),userdebug)
    ifeq ($(WITH_DEXPREOPT),)
      WITH_DEXPREOPT := true
    endif
  endif
endif
WITH_DEXPREOPT_BOOT_IMG_ONLY := true
#MALLOC_SVELTE := true

# Recovery
TARGET_USERIMAGES_USE_F2FS := true
TARGET_USERIMAGES_USE_EXT4 := true
BOARD_BOOTIMAGE_PARTITION_SIZE := 10485760 # 10M
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 20485760 # 20M
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 1027604480 # 400M
BOARD_USERDATAIMAGE_PARTITION_SIZE := 1027604480 # 400M
BOARD_FLASH_BLOCK_SIZE := 4096

BLOCK_BASED_OTA := false

# Recovery
TARGET_RECOVERY_FSTAB := device/htc/htcleo/ramdisk/fstab.htcleo
RECOVERY_FSTAB_VERSION := 2

# Render
OVERRIDE_RS_DRIVER := libRSDriver_adreno.so
USE_OPENGL_RENDERER := true

# USB
TARGET_USES_LEGACY_ADB_INTERFACE := true
