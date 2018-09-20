CC?=$(CROSS_COMPILE)gcc
DTC_OPTIONS?=-@
DTC_OPTIONS += -Wno-unit_address_vs_reg -Wno-graph_child_address -Wno-pwms_property
KERNEL_DIR?=../linux
KERNEL_BUILD_DIR?=$(KERNEL_DIR)
DTC?=$(KERNEL_BUILD_DIR)/scripts/dtc/dtc

SAMA5_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard sama*/*.dtso))
SAMA5_ITB_OBJECTS:= $(patsubst %.its,%.itb,$(wildcard sama*.its))

SAM9_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard at91sam9*/*.dtso))
SAM9_ITB_OBJECTS:= $(patsubst %.its,%.itb,$(wildcard at91sam9*.its))


%.pre.dtso: %.dtso
	$(CC) -E -nostdinc -I$(KERNEL_DIR)/include -I$(KERNEL_DIR)/arch/arm/boot/dts -x assembler-with-cpp -undef -o $@ $^

%.dtbo: %.pre.dtso
	$(DTC) $(DTC_OPTIONS) -I dts -O dtb -o $@ $^

%.itb: %.its
	mkimage -D "-i$(KERNEL_BUILD_DIR)/arch/arm/boot/ -i$(KERNEL_BUILD_DIR)/arch/arm/boot/dts -p 1000 $(DTC_OPTIONS)" -f $^ $@

sama5_dtbos: $(SAMA5_DTBO_OBJECTS)

sama5_itbs: $(SAMA5_ITB_OBJECTS)

sam9_dtbos: $(SAM9_DTBO_OBJECTS)

sam9_itbs: $(SAM9_ITB_OBJECTS)

sama5: sama5_dtbos sama5_itbs

sam9: sam9_dtbos sam9_itbs

.PHONY: clean
clean:
	rm -f $(SAMA5_DTBO_OBJECTS) $(SAM9_DTBO_OBJECTS)
	rm -f $(SAMA5_ITB_OBJECTS) $(SAM9_ITB_OBJECTS)
