.DEFAULT_GOAL := all

GCC?=$(CROSS_COMPILE)gcc
DTC?=dtc
DTC_OPTIONS?=-@
KERNEL_DIR?=../linux-at91

DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard at91*/*.dtso))
ITB_OBJECTS:= $(patsubst %.its,%.itb,$(wildcard *.its))

%.pre.dtso: %.dtso
	$(GCC) -E -nostdinc -I$(KERNEL_DIR)/include -I$(KERNEL_DIR)/arch/arm/boot/dts -x assembler-with-cpp -undef -o $@ $^

%.dtbo: %.pre.dtso
	$(DTC) $(DTC_OPTIONS) -I dts -O dtb -o $@ $^

%.itb: %.its
	mkimage -D -i$(KERNEL_DIR)/arch/arm/boot/dts -f $^ $@
	
dtbos: $(DTBO_OBJECTS)

itbs: $(ITB_OBJECTS)

all: dtbos itbs

.PHONY: clean
clean:
	rm -f $(DTBO_OBJECTS)
	rm -f $(ITB_OBJECTS)
