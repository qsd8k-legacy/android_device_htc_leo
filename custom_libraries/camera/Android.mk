ifeq ($(BOARD_VENDOR),htc)
ifeq ($(TARGET_BOARD_PLATFORM),qsd8k)

$(shell mkdir -p $(OUT)/obj/SHARED_LIBRARIES/libcamera_intermediates/)
$(shell touch $(OUT)/obj/SHARED_LIBRARIES/libcamera_intermediates/export_includes)

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_C_FLAGS          += -O3
LOCAL_MODULE_TAGS      := optional
LOCAL_MODULE_PATH      := $(TARGET_OUT_SHARED_LIBRARIES)/hw
LOCAL_MODULE           := camera.$(TARGET_BOARD_PLATFORM)

LOCAL_SRC_FILES        := QcomCamera.cpp

LOCAL_SHARED_LIBRARIES := liblog libdl libutils libcamera_client libbinder \
                          libcutils libhardware libui libhidltransport libhidlbase libhwbinder android.hardware.graphics.bufferqueue@1.0 android.hidl.token@1.0-utils

LOCAL_C_INCLUDES       := frameworks/base/services \
                          frameworks/base/include \
                          hardware/libhardware/include \
                          hardware/qcom/display/qsd8k/libgralloc \
                          system/media/camera/include

LOCAL_C_INCLUDES              += $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr/include
LOCAL_ADDITIONAL_DEPENDENCIES := $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr

LOCAL_PRELINK_MODULE   := false

include $(BUILD_SHARED_LIBRARY)

endif
endif
