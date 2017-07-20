PRODUCT_PACKAGES := ethernet.rc

PRODUCT_COPY_FILES := \
	frameworks/native/data/etc/android.hardware.ethernet.xml:system/etc/permissions/android.hardware.ethernet.xml \
        $(LOCAL_PATH)/init-net-rdu2.sh:system/bin/init-net-rdu2.sh
