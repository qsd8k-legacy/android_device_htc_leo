#
# Copyright (C) 2012 The CyanogenMod Project
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

# Release name
PRODUCT_RELEASE_NAME := htcLeo

# Bootanimation
TARGET_SCREEN_HEIGHT := 800
TARGET_SCREEN_WIDTH := 480

# Inherit AOSP base telephony
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Common Android Go configurations
$(call inherit-product, device/htc/htcleo/go_defaults.mk)

# Inherit device configuration
$(call inherit-product, device/htc/htcleo/device_htcleo.mk)

## Device identifier. This must come after all inclusions
PRODUCT_DEVICE := htcleo
PRODUCT_NAME := lineage_htcleo
PRODUCT_BRAND := htc
PRODUCT_MODEL := HTC HD2
PRODUCT_MANUFACTURER := HTC
