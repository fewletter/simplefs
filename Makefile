obj-m += simplefs.o
simplefs-objs := fs.o super.o inode.o file.o dir.o extent.o

v1PATH ?= /home/fewletter/linux2023/linux_5_18/rootfs
v2PATH ?= /home/fewletter/linux2023/linux-6.3/rootfs
VERSION ?= 

ifdef ARCH
       ARCHARG = ARCH=$(ARCH)
endif

MKFS = mkfs.simplefs

ifeq ($(VERSION), 5.18.0)
	KDIR ?= $(v1PATH)/lib/modules/$(VERSION)/build
else ifeq ($(VERSION), 6.3.0)
	KDIR ?= $(v2PATH)/lib/modules/$(VERSION)/build
else
	KDIR ?= /lib/modules/$(shell uname -r)/build
endif

all: $(MKFS)
	make -C $(KDIR) M=$(PWD) modules $(ARCHARG)

IMAGE ?= test.img
IMAGESIZE ?= 200
# To test max files(40920) in directory, the image size should be at least 159.85 MiB
# 40920 * 4096(block size) ~= 159.85 MiB

$(MKFS): mkfs.c
	$(CC) -std=gnu99 -Wall -o $@ $<

$(IMAGE): $(MKFS)
	dd if=/dev/zero of=${IMAGE} bs=1M count=${IMAGESIZE}
	./$< $(IMAGE)

check: all
	script/test.sh $(IMAGE) $(IMAGESIZE) $(MKFS)

simple_check:
	bash ./script/simple_test.sh $(IMAGE) $(IMAGESIZE) $(MKFS)

clean:
	make -C $(KDIR) M=$(PWD) clean $(ARCHARG)
	rm -f *~ $(PWD)/*.ur-safe
	rm -f $(MKFS) $(IMAGE)

.PHONY: all clean
