PROJECT_NAME := picoruby_nrf52
TARGETS := nrf52840_xxaa
OUTPUT_DIRECTORY := _build

SDK_ROOT := ./tmp/nrf52/sdk/nRF5_SDK_17.1.0_ddde560
PROJ_DIR := .

$(OUTPUT_DIRECTORY)/nrf52840_xxaa.out: LINKER_SCRIPT := linker/nrf52840.ld

SRC_FILES += \
		$(SDK_ROOT)/modules/nrfx/mdk/gcc_startup_nrf52840.S \
		$(SDK_ROOT)/modules/nrfx/mdk/system_nrf52840.c \
		$(PROJ_DIR)/main.c

INC_FOLDERS += \
		$(PROJ_DIR) \
		$(SDK_ROOT)/modules/nrfx/mdk \
		$(SDK_ROOT)/modules/nrfx/hal \
		$(SDK_ROOT)/modules/nrfx \
		$(SDK_ROOT)/integration/nrfx \
		$(SDK_ROOT)/components/toolchain/cmsis/include \
		$(PROJ_DIR)/config

CFLAGS += -DNRF52840_XXAA
CFLAGS += -mcpu=cortex-m4
CFLAGS += -mthumb -mabi=aapcs
CFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
CFLAGS += -Wall -Werror
CFLAGS += -ffunction-sections -fdata-sections -fno-strict-aliasing
CFLAGS += -fno-builtin -fshort-enums

ASMFLAGS += -mcpu=cortex-m4
ASMFLAGS += -mthumb -mabi=aapcs
ASMFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
ASMFLAGS += -DNRF52840_XXAA

LDFLAGS += -mthumb -mabi=aapcs -L$(SDK_ROOT)/modules/nrfx/mdk -T$(LINKER_SCRIPT)
LDFLAGS += -mcpu=cortex-m4
LDFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
LDFLAGS += -Wl,--gc-sections
LDFLAGS += --specs=nano.specs

LIB_FILES += -lc -lnosys -lm

default: nrf52840_xxaa

TEMPLATE_PATH := $(SDK_ROOT)/components/toolchain/gcc
include $(TEMPLATE_PATH)/Makefile.common
$(foreach target,$(TARGETS),$(call define_target,$(target)))

