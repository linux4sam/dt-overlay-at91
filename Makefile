ARCH?=arm
CC?=$(CROSS_COMPILE)gcc
DTC_OPTIONS?=-@
DTC_OPTIONS += -Wno-unit_address_vs_reg -Wno-graph_child_address -Wno-pwms_property
KERNEL_DIR?=../linux
KERNEL_BUILD_DIR?=$(shell realpath --relative-to=. $(KERNEL_DIR))
DTC?=$(KERNEL_BUILD_DIR)/scripts/dtc/dtc
BDIR?=sam9x60ek sama5d29_curiosity sama5d27_som1_ek sama5d27_wlsom1_ek sama5d2_icp sama5d2_ptc_ek sama5d2_xplained sama5d2_xplained_grts sama5d3_xplained sama5d3_eds sama5d4_xplained sama7d65_curiosity sama7g5ek sama7g54_curiosity sam9x60_curiosity sam9x75eb mpfs_icicle mpfs_icicle_amp mpfs_video pic64gx_curiosity_kit

# workaround to make mkimage use the same dtc as we do
PATH:=$(shell dirname $(DTC)):$(PATH)

AT91SAM9X5EK_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard at91sam9x5ek/*.dtso))
MPFS_ICICLE_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard mpfs_icicle/*.dtso))
MPFS_ICICLE_AMP_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard mpfs_icicle_amp/*.dtso))
MPFS_VIDEO_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard mpfs_video/*.dtso))
PIC64GX_CURIOSITY_KIT_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard pic64gx_curiosity_kit/*.dtso))
SAM9X60EK_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard sam9x60ek/*.dtso))
SAM9X60_CURIOSITY_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard sam9x60_curiosity/*.dtso))
SAM9X75EB_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard sam9x75eb/*.dtso))
SAM9X75_CURIOSITY_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard sam9x75_curiosity/*.dtso))
SAMA5D2_ICP_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard sama5d2_icp/*.dtso))
SAMA5D2_PTC_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard sama5d2_ptc_ek/*.dtso))
SAMA5D2_XPLAINED_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard sama5d2_xplained/*.dtso))
SAMA5D2_XPLAINED_GRTS_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard sama5d2_xplained_grts/*.dtso))
SAMA5D27_SOM1_EK_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard sama5d27_som1_ek/*.dtso))
SAMA5D27_WLSOM1_EK_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard sama5d27_wlsom1_ek/*.dtso))
SAMA5D29_CURIOSITY_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard sama5d29_curiosity/*.dtso))
SAMA5D3_EDS_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard sama5d3_eds/*.dtso))
SAMA5D3_XPLAINED_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard sama5d3_xplained/*.dtso))
SAMA5D4_XPLAINED_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard sama5d4_xplained/*.dtso))
SAMA7D65_CURIOSITY_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard sama7d65_curiosity/*.dtso))
SAMA7G5EK_DTBO_OBJECTS:= $(patsubst %.dtso,%.dtbo,$(wildcard sama7g5ek/*.dtso))
SAMA7G54_CURIOSITY_DTBO_OBJECTS:=$(patsubst %.dtso,%.dtbo,$(wildcard sama7g54_curiosity/*.dtso))

%.pre.dtso: %.dtso
	$(CC) -E -nostdinc -I$(KERNEL_DIR)/include -I$(KERNEL_DIR)/arch/$(ARCH)/boot/dts -I$(KERNEL_DIR)/arch/$(ARCH)/boot/dts/microchip -Iinclude -x assembler-with-cpp -undef -o $@ $^

%.dtbo: %.pre.dtso
	$(DTC) $(DTC_OPTIONS) -I dts -O dtb -o $@ $^

%.itb: %.its %_dtbos
	mkimage -D "-i$(KERNEL_BUILD_DIR)/arch/$(ARCH)/boot/ -i$(KERNEL_BUILD_DIR)/arch/$(ARCH)/boot/dts -i$(KERNEL_BUILD_DIR)/arch/$(ARCH)/boot/dts/microchip -p 1000 $(DTC_OPTIONS)" -f $< $@

at91sam9x5ek_dtbos: $(AT91SAM9X5EK_DTBO_OBJECTS)

mpfs_icicle_dtbos: $(MPFS_ICICLE_DTBO_OBJECTS)

mpfs_icicle_amp_dtbos: $(MPFS_ICICLE_AMP_DTBO_OBJECTS)

mpfs_video_dtbos: $(MPFS_VIDEO_DTBO_OBJECTS)

pic64gx_curiosity_kit_dtbos: $(PIC64GX_CURIOSITY_KIT_DTBO_OBJECTS)

sam9x60ek_dtbos: $(SAM9X60EK_DTBO_OBJECTS)

sam9x60_curiosity_dtbos: $(SAM9X60_CURIOSITY_DTBO_OBJECTS)

sam9x75eb_dtbos: $(SAM9X75EB_DTBO_OBJECTS)

sam9x75_curiosity_dtbos: $(SAM9X75_CURIOSITY_DTBO_OBJECTS)

sama5d2_icp_dtbos: $(SAMA5D2_ICP_DTBO_OBJECTS)

sama5d2_ptc_ek_dtbos: $(SAMA5D2_PTC_DTBO_OBJECTS)

sama5d2_xplained_dtbos: $(SAMA5D2_XPLAINED_DTBO_OBJECTS)

sama5d2_xplained_grts_dtbos: $(SAMA5D2_XPLAINED_GRTS_DTBO_OBJECTS)

sama5d27_som1_ek_dtbos: $(SAMA5D27_SOM1_EK_DTBO_OBJECTS)

sama5d27_wlsom1_ek_dtbos: $(SAMA5D27_WLSOM1_EK_DTBO_OBJECTS)

sama5d3_eds_dtbos: $(SAMA5D3_EDS_DTBO_OBJECTS)

sama5d29_curiosity_dtbos: $(SAMA5D29_CURIOSITY_DTBO_OBJECTS)

sama5d3_xplained_dtbos: $(SAMA5D3_XPLAINED_DTBO_OBJECTS)

sama5d4_xplained_dtbos: $(SAMA5D4_XPLAINED_DTBO_OBJECTS)

sama7d65_curiosity_dtbos: $(SAMA7D65_CURIOSITY_DTBO_OBJECTS)

sama7g5ek_dtbos: $(SAMA7G5EK_DTBO_OBJECTS)

sama7g54_curiosity_dtbos: $(SAMA7G54_CURIOSITY_DTBO_OBJECTS)

check:
	$(foreach DIR, $(BDIR), ./scripts/dt_overlay_check.sh -b $(DIR) -v;)

.PHONY: clean
clean:
	rm -f *sam*/*.dtbo *mpfs*/*.dtbo *.itb
