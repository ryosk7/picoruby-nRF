# PicoRuby nRF52 port sources and include paths.
# Included by R2P2-nRF/Makefile and components/picoruby-nRF/Makefile.
# PICORUBY_DIR and SDK_ROOT must be defined before these variables are used.

PICORUBY_NRF52_PORT_SRCS = \
	$(PICORUBY_DIR)/mrbgems/picoruby-gpio/ports/nrf52/gpio.c \
	$(PICORUBY_DIR)/mrbgems/picoruby-watchdog/ports/nrf52/watchdog.c \
	$(PICORUBY_DIR)/mrbgems/picoruby-env/ports/nrf52/env.c \
	$(PICORUBY_DIR)/mrbgems/picoruby-io-console/ports/nrf52/io-console.c \
	$(PICORUBY_DIR)/mrbgems/picoruby-littlefs/ports/nrf52/flash_hal.c \
	$(PICORUBY_DIR)/mrbgems/picoruby-irq/ports/nrf52/irq.c \
	$(PICORUBY_DIR)/mrbgems/picoruby-rng/ports/nrf52/rng.c \
	$(PICORUBY_DIR)/mrbgems/picoruby-adc/ports/nrf52/adc.c \
	$(PICORUBY_DIR)/mrbgems/picoruby-pwm/ports/nrf52/pwm.c \
	$(PICORUBY_DIR)/mrbgems/picoruby-i2c/ports/nrf52/i2c.c \
	$(PICORUBY_DIR)/mrbgems/picoruby-spi/ports/nrf52/spi.c \
	$(PICORUBY_DIR)/mrbgems/picoruby-uart/ports/nrf52/uart.c \
	$(PICORUBY_DIR)/mrbgems/picoruby-require/ports/nrf52/platform.c \
	$(PICORUBY_DIR)/mrbgems/picoruby-machine/ports/nrf52/machine.c \
	$(PICORUBY_DIR)/mrbgems/picoruby-machine/ports/common/machine.c

# The OpenThread port is the only translation unit in the tree that
# includes OpenThread's headers, which is why it is built here rather
# than by rake: this file is where the OpenThread include paths are known.
ifeq ($(NRF52_THREAD),1)
PICORUBY_NRF52_PORT_SRCS += \
	$(PICORUBY_DIR)/mrbgems/picoruby-openthread/ports/nrf52/openthread.c
endif

PICORUBY_NRF52_PORT_INCS = \
	$(PICORUBY_DIR)/mrbgems/picoruby-machine/include \
	$(PICORUBY_DIR)/mrbgems/mruby-compiler/include \
	$(PICORUBY_DIR)/mrbgems/mruby-compiler/lib/prism/include \
	$(PICORUBY_DIR)/mrbgems/picoruby-rng/include \
	$(PICORUBY_DIR)/mrbgems/picoruby-littlefs/include \
	$(PICORUBY_DIR)/mrbgems/picoruby-littlefs/lib/littlefs \
	$(SDK_ROOT)/components/libraries/fstorage

ifeq ($(NRF52_THREAD),1)
PICORUBY_NRF52_PORT_INCS += \
	$(PICORUBY_DIR)/mrbgems/picoruby-openthread/include \
	$(OPENTHREAD_INCS)
endif
