#
# Copyright (C) 2014 The Android Open-Source Project
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

define inherit-product-dirs
 $(foreach dir,$(1), \
   $(call inherit-product-if-exists, $(LOCAL_PATH)/$(dir)/device.mk) \
 )
endef

define inherit-product-if-true
 $(call inherit-product-if-exists, $(if $(filter true,$(1)),$(2)))
endef

define add-to-product-copy-files-if-true
 $(call add-to-product-copy-files-if-exists, $(if $(filter true,$(1)),$(2)))
endef

ifneq ($(CONFIG_64_BIT),)
ifeq ($(CONFIG_HAS_2ND_ARCH),)
        $(call inherit-product, $(LOCAL_PATH)/device_64only.mk)
else
        $(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
endif
endif

$(call inherit-product-if-true, $(CONFIG_TV), $(LOCAL_PATH)/device_tv.mk)
$(call inherit-product-if-true, $(CONFIG_TABLET), $(LOCAL_PATH)/device_tablet.mk)

PRODUCT_NAME := $(TARGET_PRODUCT)
PRODUCT_BRAND := Android


PRODUCT_PACKAGES += \
    perf \
    tcpdump \
    ethtool \
    brctl

DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay

PRODUCT_COPY_FILES += \
	$(call add-to-product-copy-files-if-true, $(CONFIG_KERNEL), \
		$(CONFIG_KERNEL_PATH):kernel)

$(foreach dev,$(wildcard vendor/*/*/device-partial.mk), $(call inherit-product, $(dev)))

PRODUCT_COPY_FILES += $(call add-to-product-copy-files-if-exists,\
			system/core/rootdir/init.rc:root/init.rc \
			$(LOCAL_PATH)/init.rc:root/init.unknown.rc \
			$(LOCAL_PATH)/ueventd.rc:root/ueventd.unknown.rc \
			$(LOCAL_PATH)/fstab:root/fstab.unknown)

PRODUCT_COPY_FILES += $(call add-to-product-copy-files-if-exists,\
	$(LOCAL_PATH)/a300_pfp.fw:root/lib/firmware/a300_pfp.fw \
	$(LOCAL_PATH)/a300_pm4.fw:root/lib/firmware/a300_pm4.fw \
)

PRODUCT_COPY_FILES += \
    frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:system/etc/media_codecs_google_audio.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_video.xml:system/etc/media_codecs_google_video.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:system/etc/permissions/android.hardware.usb.host.xml \
    $(LOCAL_PATH)/media_codecs.xml:system/etc/media_codecs.xml \

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/gadgets.rc:system/etc/init/gadgets.rc \
    $(LOCAL_PATH)/init.sh:system/bin/init.sh \

PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.heapstartsize=$(CONFIG_DALVIK_VM_HEAPSTARTSIZE)m \
    dalvik.vm.heapgrowthlimit=$(CONFIG_DALVIK_VM_HEAPGROWTHLIMIT)m \
    dalvik.vm.heapsize=$(CONFIG_DALVIK_VM_HEAPSIZE)m \
    dalvik.vm.heaptargetutilization=0.75 \
    dalvik.vm.heapminfree=512k \
    dalvik.vm.heapmaxfree=$(CONFIG_DALVIK_VM_HEAPMAXFREE)m

subdirs-true := lights graphics
subdirs-$(CONFIG_WIFI) += wifi
subdirs-$(CONFIG_ETHERNET) += ethernet
subdirs-$(CONFIG_SENSOR) += sensor
$(call inherit-product-dirs, $(subdirs-true))
