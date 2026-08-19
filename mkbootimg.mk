#
# Custom mkbootimg.mk for Htc HD2 (leo)
#


LOCAL_PATH := $(call my-dir)

# Path to mkbootimg
MKBOOTIMG := system/core/mkbootimg/mkbootimg
PADDING := $(LOCAL_PATH)/padding

INSTALLED_KERNEL_TARGET := $(PRODUCT_OUT)/kernel

INSTALLED_RAMDISK_TARGET := $(PRODUCT_OUT)/ramdisk.img
PADDED_RAMDISK_TARGET := $(PRODUCT_OUT)/ramdisk-padded.stamp

INSTALLED_RECOVERY_RAMDISK_TARGET := $(PRODUCT_OUT)/ramdisk-recovery.img
PADDED_RECOVERY_RAMDISK_TARGET := $(PRODUCT_OUT)/ramdisk-recovery-padded.stamp

# Pad the normal ramdisk (in-place). We can't redefine the recipe for
# $(INSTALLED_RAMDISK_TARGET) itself (it's already built by
# build/make/core/Makefile), so use a stamp file to sequence the
# in-place padding after it's built.
$(PADDED_RAMDISK_TARGET): $(INSTALLED_RAMDISK_TARGET) $(PADDING)
	$(call pretty,"Target padded ramdisk: $(INSTALLED_RAMDISK_TARGET)")
	$(hide) mkdir -p $(dir $@)
	$(hide) mv $(INSTALLED_RAMDISK_TARGET) $(INSTALLED_RAMDISK_TARGET).orig
	$(hide) cat $(PADDING) $(INSTALLED_RAMDISK_TARGET).orig > $(INSTALLED_RAMDISK_TARGET)
	$(hide) touch $@

# Pad the recovery ramdisk (in-place). Same reasoning as above.
$(PADDED_RECOVERY_RAMDISK_TARGET): $(INSTALLED_RECOVERY_RAMDISK_TARGET) $(PADDING)
	$(call pretty,"Target padded recovery ramdisk: $(INSTALLED_RECOVERY_RAMDISK_TARGET)")
	$(hide) mkdir -p $(dir $@)
	$(hide) mv $(INSTALLED_RECOVERY_RAMDISK_TARGET) $(INSTALLED_RECOVERY_RAMDISK_TARGET).orig
	$(hide) cat $(PADDING) $(INSTALLED_RECOVERY_RAMDISK_TARGET).orig > $(INSTALLED_RECOVERY_RAMDISK_TARGET)
	$(hide) touch $@


# Boot image
$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES) $(BOOTIMAGE_EXTRA_DEPS) $(PADDED_RAMDISK_TARGET)
	$(call pretty,"Target boot image: $@")
	$(hide) $(MKBOOTIMG) \
		$(INTERNAL_BOOTIMAGE_ARGS) \
		$(INTERNAL_MKBOOTIMG_VERSION_ARGS) \
		$(BOARD_MKBOOTIMG_ARGS) \
		--kernel $(INSTALLED_KERNEL_TARGET) \
		--output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_BOOTIMAGE_PARTITION_SIZE))

# Recovery image
$(INSTALLED_RECOVERYIMAGE_TARGET): $(recoveryimage-deps) $(RECOVERYIMAGE_EXTRA_DEPS) $(PADDED_RECOVERY_RAMDISK_TARGET)
	$(call pretty,"Target recovery image: $@")
	$(hide) $(MKBOOTIMG) \
		$(INTERNAL_RECOVERYIMAGE_ARGS) \
		$(INTERNAL_MKBOOTIMG_VERSION_ARGS) \
		$(BOARD_MKBOOTIMG_ARGS) \
		--kernel $(INSTALLED_KERNEL_TARGET) \
		--output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE))