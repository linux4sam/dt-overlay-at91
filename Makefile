GCC?=$(CROSS_COMPILE)gcc
DTC?=dtc
DTC_OPTIONS?=-@
KERNEL_DIR?=../linux-at91

OBJECTS:= $(patsubst %.dts,%.dtbo,$(wildcard overlays/*.dts))

%.pre.dts: %.dts
	$(GCC) -E -nostdinc -I$(KERNEL_DIR)/include -I$(KERNEL_DIR)/arch/arm/boot/dts -x assembler-with-cpp -undef -o $@ $^

%.dtbo: %.pre.dts
	$(DTC) $(DTC_OPTIONS) -I dts -O dtb -o $@ $^

all: $(OBJECTS)

clean:
	rm -f $(OBJECTS)
