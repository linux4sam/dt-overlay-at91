CC?=$(CROSS_COMPILE)gcc
DTC_OPTIONS?=-@
DTC_OPTIONS += -Wno-unit_address_vs_reg -Wno-graph_child_address -Wno-pwms_property
KERNEL_DIR?=../linux
KERNEL_BUILD_DIR?=$(KERNEL_DIR)
DTC?=$(KERNEL_BUILD_DIR)/scripts/dtc/dtc

# workaround to make mkimage use the same dtc as we do
PATH:=$(shell dirname $(DTC)):$(PATH)

AT91SAM9X5EK_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard at91sam9x5ek/*.dtso))
SAM9X60EK_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard sam9x60ek/*.dtso))
SAMA5D27_SOM1_EK_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard sama5d27_som1_ek/*.dtso))
SAMA5D27_WLSOM1_EK_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard sama5d27_wlsom1_ek/*.dtso))
SAMA5D2_ICP_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard sama5d2_icp/*.dtso))
SAMA5D2_PTC_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard sama5d2_ptc_ek/*.dtso))
SAMA5D2_XPLAINED_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard sama5d2_xplained/*.dtso))
SAMA5D2_XPLAINED_GRTS_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard sama5d2_xplained_grts/*.dtso))
SAMA5D3_XPLAINED_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard sama5d3_xplained/*.dtso))
SAMA5D4_XPLAINED_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard sama5d4_xplained/*.dtso))

%.pre.dtso: %.dtso
	$(CC) -E -nostdinc -I$(KERNEL_DIR)/include -I$(KERNEL_DIR)/arch/arm/boot/dts -x assembler-with-cpp -undef -o $@ $^

%.dtbo: %.pre.dtso
	$(DTC) $(DTC_OPTIONS) -I dts -O dtb -o $@ $^

%.itb: %.its %_dtbos
	mkimage -D "-i$(KERNEL_BUILD_DIR)/arch/arm/boot/ -i$(KERNEL_BUILD_DIR)/arch/arm/boot/dts -p 1000 $(DTC_OPTIONS)" -f $< $@

at91sam9x5ek_dtbos: $(AT91SAM9X5EK_DTBO_OBJECTS)

sam9x60ek_dtbos: $(SAM9X60EK_DTBO_OBJECTS)

sama5d27_som1_ek_dtbos: $(SAMA5D27_SOM1_EK_DTBO_OBJECTS)

sama5d27_wlsom1_ek_dtbos: $(SAMA5D27_WLSOM1_EK_DTBO_OBJECTS)

sama5d2_icp_dtbos: $(SAMA5D2_ICP_DTBO_OBJECTS)

sama5d2_ptc_ek_dtbos: $(SAMA5D2_PTC_DTBO_OBJECTS)

sama5d2_xplained_dtbos: $(SAMA5D2_XPLAINED_DTBO_OBJECTS)

sama5d2_xplained_grts_dtbos: $(SAMA5D2_XPLAINED_GRTS_DTBO_OBJECTS)

sama5d3_xplained_dtbos: $(SAMA5D3_XPLAINED_DTBO_OBJECTS)

sama5d4_xplained_dtbos: $(SAMA5D4_XPLAINED_DTBO_OBJECTS)

.PHONY: clean
clean:
	rm -f *sam*/*.dtbo *.itb
