TMP_INITRAMFSROOT = .tmp/initramfsroot
TMP_INITRAMFS = .tmp/initramfs
TMP_MODLOOP = .tmp/modloop
INITRD_MODS = n
LINUX_PKG = $(wildcard linux*.tar.xz)

all: uInitrd modloop-custom
	@echo "Done"

clean:
	rm -rf .tmp uInitrd-* modloop-new
	@echo "Done"

.PHONY: uInitrd
uInitrd: src/initramfs-orig
	@[ -f "$(LINUX_PKG)" ] || (echo "Invalid LINUX_PKG ($(LINUX_PKG))" && false)
	rm -rf $(TMP_INITRAMFSROOT) && mkdir -p $(TMP_INITRAMFSROOT)
	gunzip -c < $^ | (cd $(TMP_INITRAMFSROOT) && cpio -idv)
	rm -rf $(TMP_INITRAMFSROOT)/lib/modules && mkdir -p $(TMP_INITRAMFSROOT)/lib/modules
	@if [ "$(INITRD_MODS)" = y ]; then tar -xvf "$(LINUX_PKG)" -C $(TMP_INITRAMFSROOT) lib/modules; fi
	(cd $(TMP_INITRAMFSROOT) && find . | cpio -H newc -o) > $(TMP_INITRAMFS)
	mkimage -A arm -T ramdisk -C none -d $(TMP_INITRAMFS) $@
	rm -rf $(TMP_INITRAMFSROOT) $(TMP_INITRAMFS)

.PHONY: uInitrd-dontuse
uInitrd-dontuse:
	sudo chroot ./alpine_root sh -c "rm -rf /lib/modules && mkdir -p /lib/modules"
	sudo tar -xvf "$(LINUX_PKG)" -C alpine_root lib/modules
	sudo chroot ./alpine_root mkinitfs -o /initrd $(shell cat kernelrelease)
	sudo mv alpine_root/initrd ./initrd && sudo chown bachnx:bachnx ./initrd
	mkimage -A arm -T ramdisk -C none -d initrd uInitrd-base
	rm -rf $(TMP_INITRAMFSROOT) initrd

.PHONY: modloop-custom
modloop-custom: src/modloop-orig
	@[ -f "$(LINUX_PKG)" ] || (echo "Invalid LINUX_PKG ($(LINUX_PKG))" && false)
	rm -rf $(TMP_MODLOOP)
	unsquashfs -d $(TMP_MODLOOP) $^
	rm -rf $(TMP_MODLOOP)/modules/*-lts # Warn: dirty
	tar -xvf "$(LINUX_PKG)" -C $(TMP_MODLOOP) lib/modules --strip-components=1
	mksquashfs $(TMP_MODLOOP) $@ -comp xz
	rm -rf $(TMP_MODLOOP)

chroot:
	@echo "Spawing chroot shell..."
	@sudo chroot ./alpine_root su - root

help:
	@echo No Help available
