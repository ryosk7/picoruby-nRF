PICORUBY_NRF52_ROOT ?= $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)
PICORUBY_NRF52_ROOT := $(PICORUBY_NRF52_ROOT)
NRF52_FAMILY_ROOT := $(PICORUBY_NRF52_ROOT)/nrf52
NRF5_SDK_VERSION ?= nRF5_SDK_17.1.0_ddde560
NRF5_SDK_VERSION := $(NRF5_SDK_VERSION)
NRF5_SDK_ROOT := $(NRF52_FAMILY_ROOT)/sdk/$(NRF5_SDK_VERSION)
# Selected below once NRF52_THREAD is known.
NRF52_LINKER_SCRIPT := $(PICORUBY_NRF52_ROOT)/linker/nrf52840.ld
NRF52_SDK_CONFIG_DIR := $(PICORUBY_NRF52_ROOT)/config
NRF52_STARTUP_SRC := $(PICORUBY_NRF52_ROOT)/ports/nrf52/startup_nrf52840.c

# OpenThread, via ot-nrf528xx (github.com/openthread/ot-nrf528xx).
#
# Placed under nrf52/ by hand exactly as the nRF5 SDK is, and overridable
# for a tree kept elsewhere. Off by default: the sources are not vendored,
# so a checkout without them still builds. Turn it on with NRF52_THREAD=1.
NRF52_THREAD ?= 0
OPENTHREAD_ROOT ?= $(NRF52_FAMILY_ROOT)/openthread
OPENTHREAD_ROOT := $(OPENTHREAD_ROOT)
OPENTHREAD_BUILD ?= $(OPENTHREAD_ROOT)/build_picoruby
OPENTHREAD_BUILD := $(OPENTHREAD_BUILD)
OPENTHREAD_LIB_DIR := $(OPENTHREAD_BUILD)/lib

OPENTHREAD_INCS := \
	$(OPENTHREAD_ROOT)/openthread/include \
	$(OPENTHREAD_ROOT)/src/nrf52840 \
	$(OPENTHREAD_ROOT)/src \
	$(OPENTHREAD_ROOT)/openthread/examples/platforms

# libnordicsemi-nrf52840-sdk.a is deliberately absent. It is ot-nrf528xx's
# own extract of the nRF5 SDK -- startup, SystemInit, nrfx clock/power,
# nrf_nvmc, app_util -- for standalone OpenThread apps. This firmware
# already supplies all of it from SDK $(NRF5_SDK_VERSION), and linking
# both produces 54 duplicate-symbol errors.
OPENTHREAD_LIBS := \
	$(OPENTHREAD_LIB_DIR)/libopenthread-mtd.a \
	$(OPENTHREAD_LIB_DIR)/libopenthread-nrf52840.a \
	$(OPENTHREAD_LIB_DIR)/libopenthread-platform-utils-static.a \
	$(OPENTHREAD_LIB_DIR)/libnordicsemi-nrf52840-radio-driver.a \
	$(OPENTHREAD_LIB_DIR)/libmbedcrypto.a

ifeq ($(NRF52_THREAD),1)
# The Thread map reclaims the SoftDevice regions and adds the OpenThread
# settings area. Read the warning at the top of that file before flashing.
NRF52_LINKER_SCRIPT := $(PICORUBY_NRF52_ROOT)/linker/nrf52840-thread.ld
endif
