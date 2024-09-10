# Release name
PRODUCT_RELEASE_NAME := Leo

# Boot animation
TARGET_SCREEN_HEIGHT := 800
TARGET_SCREEN_WIDTH := 480

# Inherit some common CM stuff.
$(call inherit-product, vendor/unlegacy/configs/common.mk)

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base_telephony.mk)

# Inherit device configuration
$(call inherit-product, device/htc/leo/device_leo.mk)

## Device identifier. This must come after all inclusions
PRODUCT_DEVICE := leo
PRODUCT_NAME := aosp_leo
PRODUCT_BRAND := htc
PRODUCT_MODEL := Htc Hd2
PRODUCT_MANUFACTURER := HTC
