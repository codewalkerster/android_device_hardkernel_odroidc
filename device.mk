#
# Copyright (C) 2007 The Android Open Source Project
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

# This is a generic Amlogic product
# It includes the base Android platform.

PRODUCT_PACKAGES := \
    drmserver \
    libdrmframework \
    libdrmframework_jni \
    libfwdlockengine \
    OpenWnn \
    libWnnEngDic \
    libWnnJpnDic \
    libwnndict \
    Contacts \
    ContactsProvider \
    WAPPushManager

# Live Wallpapers
PRODUCT_PACKAGES += \
    Galaxy4 \
    HoloSpiralWallpaper \
    LiveWallpapers \
    LiveWallpapersPicker \
    MagicSmokeWallpapers \
    NoiseField \
    PhaseBeam \
    VisualizationWallpapers

# Additional settings used in all AOSP builds
PRODUCT_PROPERTY_OVERRIDES := \
    ro.com.android.dateformat=MM-dd-yyyy \
    ro.config.ringtone=Ring_Synth_04.ogg \
    ro.config.notification_sound=pixiedust.ogg

# Put en_US first in the list, so make it default.
PRODUCT_LOCALES := en_US

# needed for ASEC
PRODUCT_PACKAGES += \
    make_ext4fs \
    setup_fs

PRODUCT_PACKAGES += \
    busybox \
    utility_busybox \
    ntfs-3g \
    fsck.exfat mount.exfat

# Mali GPU OpenGL libraries
PRODUCT_PACKAGES += \
    libEGL_mali \
    libGLESv1_CM_mali \
    libGLESv2_mali \
    libGLESv2_mali \
    libMali \
    libUMP \
    mali.ko \
    ump.ko \
    egl.cfg \
    gralloc.amlogic \
    hwcomposer.amlogic

# Player
PRODUCT_PACKAGES += \
    amlogic.subtitle.xml \
    amlogic.libplayer.xml

# 4k2k Image Player
PRODUCT_PACKAGES += \
    imageserver
    
# Amlogic RIL
PRODUCT_PACKAGES += \
	Phone       \
	usb_modeswitch \
	libaml-ril.so \
	init-pppd.sh \
	rild \
	ip-up \
	chat

#Camera & Sensors Hal
PRODUCT_PACKAGES += \
	camera.amlogic

# libemoji for Webkit
PRODUCT_PACKAGES += libemoji

#USB PM
PRODUCT_PACKAGES += \
    usbtestpm \
    usbpower

PRODUCT_PACKAGES += \
    su

PRODUCT_PACKAGES += \
    static-toolbox \
    updater

# GPS
PRODUCT_PACKAGES += \
    gps.odroidc

# Bluetooth
PRODUCT_PACKAGES += \
    bluetooth.default \
    Bluetooth

# odroid sensor
PRODUCT_PACKAGES += \
    sensors.odroidc

PRODUCT_COPY_FILES += \
    device/hardkernel/common/tools/AmlHostsTool:system/bin/AmlHostsTool

#possible options:1 mass_storage 2 mtp
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
	persist.sys.usb.config=mass_storage \
	ro.kernel.android.checkjni=0

# USB
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.usb.host.xml:system/etc/permissions/android.hardware.usb.host.xml \
	frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml	

#copy all possible idc to target
PRODUCT_COPY_FILES += \
    device/hardkernel/common/idc/ft5x06.idc:system/usr/idc/ft5x06.idc \
    device/hardkernel/common/idc/pixcir168.idc:system/usr/idc/pixcir168.idc \
    device/hardkernel/common/idc/ssd253x-ts.idc:system/usr/idc/ssd253x-ts.idc \
    device/hardkernel/common/idc/Vendor_222a_Product_0001.idc:system/usr/idc/Vendor_222a_Product_0001.idc \
    device/hardkernel/common/idc/Vendor_dead_Product_beef.idc:system/usr/idc/Vendor_dead_Product_beef.idc

#cp kl file for adc keyboard
PRODUCT_COPY_FILES += \
	$(TARGET_PRODUCT_DIR)/Vendor_0001_Product_0001.kl:/system/usr/keylayout/Vendor_0001_Product_0001.kl
#copy set_display_mode.sh
PRODUCT_COPY_FILES += \
	$(TARGET_PRODUCT_DIR)/set_display_mode.sh:system/bin/set_display_mode.sh  \
	$(TARGET_PRODUCT_DIR)/preinstall.sh:system/bin/preinstall.sh \
	$(TARGET_PRODUCT_DIR)/set_density.sh:system/bin/set_density.sh \
	$(TARGET_PRODUCT_DIR)/ups3.sh:system/bin/ups3.sh \
	$(TARGET_PRODUCT_DIR)/makebootini.sh:system/bin/makebootini.sh \
	$(TARGET_PRODUCT_DIR)/usb_reset.sh:system/bin/usb_reset.sh

#copy zram_mount.sh
PRODUCT_COPY_FILES += \
	$(TARGET_PRODUCT_DIR)/zram_mount.sh:system/bin/zram_mount.sh 
	
ifneq ($(wildcard frameworks/base/Android.mk),)
PRODUCT_COPY_FILES += \
	packages/wallpapers/LivePicker/android.software.live_wallpaper.xml:system/etc/permissions/android.software.live_wallpaper.xml
endif

ifneq ($(wildcard frameworks/base/Android.mk),)
# Overlay for device specific settings
DEVICE_PACKAGE_OVERLAYS := $(TARGET_PRODUCT_DIR)/overlay
endif


ifneq ($(wildcard $(TARGET_PRODUCT_DIR)/mali.ko),)
PRODUCT_COPY_FILES += $(TARGET_PRODUCT_DIR)/mali.ko:root/boot/mali.ko
endif

ifneq ($(wildcard $(TARGET_PRODUCT_DIR)/ump.ko),)
PRODUCT_COPY_FILES += $(TARGET_PRODUCT_DIR)/ump.ko:root/boot/ump.ko
endif

#Wi-Fi #4 Firmware
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rt2870.bin:root/lib/firmware/rt2870.bin

$(call inherit-product-if-exists, external/libusb/usbmodeswitch/CopyConfigs.mk)
$(call inherit-product-if-exists, hardware/amlogic/libril/config/Copy.mk)


# Get some sounds
$(call inherit-product-if-exists, frameworks/base/data/sounds/AllAudio.mk)

# Get the TTS language packs
$(call inherit-product-if-exists, external/svox/pico/lang/all_pico_languages.mk)

# Get a list of languages.
$(call inherit-product, $(SRC_TARGET_DIR)/product/locales_full.mk)

# Get everything else from the parent package
#$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_no_telephony.mk)
$(call inherit-product, device/hardkernel/common/generic_no_telephony_amlogic.mk)

DISPLAY_BUILD_NUMBER := true
