#if use prebuilt kernel or build kernel from source code
-include device/hardkernel/common/gpu.mk

INSTALLED_KERNEL_TARGET := $(PRODUCT_OUT)/kernel

KERNEL_DEVICETREE := meson8b_odroidc
KERNEL_DEFCONFIG := odroidc_defconfig

KERNEL_ROOTDIR := kernel
KERNEL_OUT := $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ
KERNEL_CONFIG := $(KERNEL_OUT)/.config
KERNEL_MODULES_INSTALL := system
KERNEL_MODULES_OUT := $(TARGET_OUT)/lib/modules
INTERMEDIATES_KERNEL := $(KERNEL_OUT)/arch/arm/boot/uImage
BOARD_MKBOOTIMG_ARGS := --second $(KERNEL_OUT)/arch/arm/boot/dts/$(KERNEL_DEVICETREE).dtb
TARGET_AMLOGIC_INT_KERNEL := $(KERNEL_OUT)/arch/arm/boot/uImage
TARGET_AMLOGIC_INT_RECOVERY_KERNEL := $(KERNEL_OUT)/arch/arm/boot/uImage_recovery
BACKPORTS_PATH := hardware/backports

PREFIX_CROSS_COMPILE=arm-linux-gnueabihf-

define cp-modules
mkdir -p $(PRODUCT_OUT)/root/boot

cp $(MALI_OUT)/mali.ko $(PRODUCT_OUT)/root/boot
cp $(KERNEL_OUT)/arch/arm/boot/dts/$(KERNEL_DEVICETREE).dtb $(PRODUCT_OUT)/$(KERNEL_DEVICETREE).dtb
endef

define mv-modules
mdpath=`find $(KERNEL_MODULES_OUT) -type f -name modules.dep`;\
	if [ "$$mdpath" != "" ]; then \
	mpath=`dirname $$mdpath`;\
	ko=`find $$mpath/kernel $$mpath/hardware -type f -name *.ko`;\
	for i in $$ko; do echo $$i; mv $$i $(KERNEL_MODULES_OUT)/; done;\
	fi;\
	ko=`find hardware/backports -type f -name *.ko`;\
	mkdir -p $(KERNEL_MODULES_OUT)/backports; \
	for i in $$ko; do echo $$i; mv $$i $(KERNEL_MODULES_OUT)/backports/; done;
endef

define clean-module-folder
mdpath=`find $(KERNEL_MODULES_OUT) -type f -name modules.dep`;\
       if [ "$$mdpath" != "" ];then\
       mpath=`dirname $$mdpath`; rm -rf $$mpath;\
       fi
endef

$(KERNEL_OUT):
	mkdir -p $(KERNEL_OUT)

$(KERNEL_CONFIG): $(KERNEL_OUT)
	$(MAKE) -C $(KERNEL_ROOTDIR) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) $(KERNEL_DEFCONFIG)

$(INTERMEDIATES_KERNEL): $(KERNEL_OUT) $(KERNEL_CONFIG)
	@echo "make uImage"
	$(MAKE) -C $(KERNEL_ROOTDIR) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) uImage
	$(MAKE) -C $(KERNEL_ROOTDIR) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) modules
	$(MAKE) -C $(KERNEL_ROOTDIR) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) INSTALL_MOD_PATH=../../$(KERNEL_MODULES_INSTALL) INSTALL_MOD_STRIP=1 modules_install
	$(MAKE) -C $(KERNEL_ROOTDIR) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) dtbs
	$(MAKE) -C $(BACKPORTS_PATH) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) KLIB_BUILD=../../$(KERNEL_OUT) defconfig-odroidc
	$(MAKE) -C $(BACKPORTS_PATH) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) KLIB_BUILD=../../$(KERNEL_OUT)
	$(cp-modules)
	$(mv-modules)
	$(clean-module-folder)

kerneltags: $(KERNEL_OUT)
	$(MAKE) -C $(KERNEL_ROOTDIR) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) tags
kernelconfig: $(KERNEL_OUT) $(KERNEL_CONFIG)
	env KCONFIG_NOTIMESTAMP=true \
	     $(MAKE) -C $(KERNEL_ROOTDIR) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) menuconfig

savekernelconfig: $(KERNEL_OUT) $(KERNEL_CONFIG)
	env KCONFIG_NOTIMESTAMP=true \
	     $(MAKE) -C $(KERNEL_ROOTDIR) O=../$(KERNEL_OUT) ARCH=arm CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) savedefconfig
	cp $(KERNEL_OUT)/defconfig $(KERNEL_ROOTDIR)/customer/configs/$(KERNEL_DEFCONFIG)

$(INSTALLED_KERNEL_TARGET): $(INTERMEDIATES_KERNEL) | $(ACP)
	@echo "Kernel installed"
	$(transform-prebuilt-to-target)
