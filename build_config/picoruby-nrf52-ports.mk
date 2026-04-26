# PicoRuby nRF52 port sources and include paths.
# Included by R2P2-nRF/Makefile and components/picoruby-nRF/Makefile.
# PICORUBY_DIR and SDK_ROOT must be defined before these variables are used.

PICORUBY_NRF52_PORT_SRCS = \
	$(PICORUBY_DIR)/mrbgems/picoruby-gpio/ports/nrf52/gpio.c \
	$(PICORUBY_DIR)/mrbgems/picoruby-watchdog/ports/nrf52/watchdog.c \
	$(PICORUBY_DIR)/mrbgems/picoruby-env/ports/nrf52/env.c \
	$(PICORUBY_DIR)/mrbgems/picoruby-io-console/ports/nrf52/io-console.c \
	$(PICORUBY_DIR)/mrbgems/picoruby-littlefs/ports/nrf52/flash_hal.c \
	$(PICORUBY_DIR)/mrbgems/picoruby-machine/ports/nrf52/machine.c

PICORUBY_NRF52_PORT_INCS = \
	$(PICORUBY_DIR)/mrbgems/picoruby-machine/include \
	$(SDK_ROOT)/components/libraries/fstorage
