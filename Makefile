#
# Basic testing and demonstration framework for this tool
#

# Location to fetch an example image from
URL_BASE := http://cdimage.debian.org/cdimage/release/current/amd64/iso-cd/
URL_NAME = debian-$(shell cat version.txt).0-amd64-netinst.iso

# Which preseed files to add to our test images
TEST_PRESEED_CFG := \
    examples/accounts.cfg \
    examples/auto-install.cfg \
    examples/finish.cfg \
    examples/hostname.cfg \
    examples/locale.cfg \
    examples/mirror.cfg \
    examples/network-console.cfg \
    examples/popcon.cfg \
    examples/proxy.cfg \
    examples/scan-cdrom.cfg \
    examples/tasksel.cfg \

all:
	@echo no default target
	exit 1

.PHONY: build-dep
build-dep:
	sudo apt-get -y install wget \
	    xorriso isolinux ovmf

Release:
	wget -O $@ http://httpredir.debian.org/debian/dists/stable/Release
REALLYCLEAN += Release

version.txt: Release
	grep ^Version: $< |head -1 |cut -d" " -f2 >$@
REALLYCLEAN += version.txt

debian.iso: version.txt
	wget -O $@ $(URL_BASE)/$(URL_NAME)
	touch $@
REALLYCLEAN += debian.iso

repack.iso repack.txt: debian.iso $(TEST_PRESEED_CFG)
	./repack -a -s -i $< -o repack.iso $(TEST_PRESEED_CFG)
	echo "Version: $(shell cat version.txt)" >repack.txt
	echo "Fragments: $(TEST_PRESEED_CFG)" >>repack.txt
CLEAN += repack.iso

clean:
	rm -f $(CLEAN)

reallyclean: clean
	rm -f $(REALLYCLEAN)

# Automated testing targets
test: repack.iso

# Some definitions to help with manual testing
#
# Note:
# - As there is no hard drive configured in these test VMs, actually
#   installing is not possible.
# - These dont test booting from a USB stick, which is subtly different.
#
QEMU_RAM := 1500
QEMU_CMD_NET := \
    -netdev type=user,id=e0,hostfwd=::4022-:22 \
    -device virtio-net-pci,netdev=e0
QEMU_CMD_EFI := \
    -drive if=pflash,format=raw,readonly,file=/usr/share/OVMF/OVMF_CODE.fd \
    -drive if=pflash,format=raw,file=OVMF_VARS.fd

QEMU_CMD := qemu-system-x86_64 \
    -machine pc,accel=kvm:tcg -cpu qemu64,-svm \
    -hda hda \
    -m $(QEMU_RAM)

OVMF_VARS.fd: /usr/share/OVMF/OVMF_VARS.fd
	cp $< $@
CLEAN += OVMF_VARS.fd

hda:
	truncate -s 10G hda
REALLYCLEAN += hda

.PHONY: test_qemu_bios
test_qemu_bios: repack.iso hda
	$(QEMU_CMD) $(QEMU_CMD_NET) -cdrom $<

.PHONY: test_qemu_efi
test_qemu_efi: repack.iso hda OVMF_VARS.fd
	$(QEMU_CMD) $(QEMU_CMD_NET) $(QEMU_CMD_EFI) -cdrom $<
