#
# Basic testing and demonstration framework for this tool
#

# Location to fetch an example image from
URL := http://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/current/amd64/iso-cd/firmware-10.5.0-amd64-netinst.iso

all:
	@echo no default target
	exit 1

.PHONY: build-dep
build-dep:
	sudo apt-get -y install wget

debian.iso:
	wget -O $@ $(URL)

repack.iso: debian.iso
	echo fake it until make it
	cp $< $@
