# The build name carries the variant, so the two configurations do not
# share build/nrf52/. Without this, libmruby.a survives a switch of
# NRF52_THREAD -- Makefile:247 makes it depend only on $(MRUBY_CONFIG) --
# and objects compiled with MRBC_TASK_SCHEDULER_HOOK link against ones
# compiled without it, which is an ODR violation rather than a link error.
MRuby::CrossBuild.new(ENV["NRF52_THREAD"] == "1" ? "nrf52-thread" : "nrf52") do |conf|
  sdk_root = File.expand_path("../nrf52/sdk/nRF5_SDK_17.1.0_ddde560", __dir__)

  conf.toolchain("gcc")

  conf.cc.command = "arm-none-eabi-gcc"
  conf.linker.command = "arm-none-eabi-ld"
  conf.archiver.command = "arm-none-eabi-ar"

  conf.cc.host_command = "gcc"
  conf.cc.flags << "-Wall"
  conf.cc.flags << "-mcpu=cortex-m4"
  conf.cc.flags << "-mthumb"
  conf.cc.flags << "-mfloat-abi=hard"
  conf.cc.flags << "-mfpu=fpv4-sp-d16"
  conf.cc.defines << "NRF52840_XXAA"
  conf.cc.defines << "CONFIG_GPIO_AS_PINRESET"
  conf.cc.include_paths << "#{sdk_root}/modules/nrfx/hal"
  conf.cc.include_paths << "#{sdk_root}/modules/nrfx/mdk"
  conf.cc.include_paths << "#{sdk_root}/integration/nrfx"
  conf.cc.include_paths << "#{sdk_root}/modules/nrfx"
  conf.cc.include_paths << "#{sdk_root}/components/libraries/util"
  conf.cc.include_paths << "#{sdk_root}/components/libraries/fstorage"
  conf.cc.include_paths << "#{sdk_root}/components/libraries/experimental_section_vars"
  conf.cc.include_paths << "#{sdk_root}/components/toolchain/cmsis/include"
  conf.cc.include_paths << "#{sdk_root}/components/drivers_nrf/nrf_soc_nosd"
  conf.cc.include_paths << File.expand_path("../config", __dir__)

  conf.cc.defines << "MRBC_TICK_UNIT=10"
  conf.cc.defines << "MRBC_TIMESLICE_TICK_COUNT=1"
  conf.cc.defines << "MRBC_USE_FLOAT=2"
  conf.cc.defines << "PICORUBY_INT64"
  # Selects the nRF52 arms of the shared headers -- UART_UNIT_MAX and the
  # IRQ source registry both branch on it.
  conf.cc.defines << "PICORB_PLATFORM_NRF52"
  conf.cc.defines << "NDEBUG"

  conf.femtoruby(alloc_libc: false)
  conf.gembox "minimum"
  conf.gembox "core"
  conf.gem core: "picoruby-gpio"
  conf.gem core: "picoruby-irq"
  conf.gem core: "picoruby-rng"
  conf.gem core: "picoruby-adc"
  conf.gem core: "picoruby-pwm"
  conf.gem core: "picoruby-i2c"
  conf.gem core: "picoruby-spi"
  conf.gem core: "picoruby-uart"
  conf.gem core: "picoruby-shell"
  conf.gem core: "picoruby-watchdog"
  if ENV["NRF52_THREAD"] == "1"
    # Thread over the on-chip 802.15.4 radio. Mutually exclusive with BLE:
    # one radio, and this build has no SoftDevice.
    conf.gem core: "picoruby-openthread"
    # Drives OpenThread's tasklet loop from the mruby/c run loop, and
    # switches on picoruby-irq's event bridge at the same time. Must match
    # the Makefile side (CPPFLAGS) or picoruby-irq/include/irq.h derives a
    # different PICORB_IRQ_EVENT_BRIDGE on either half of the build.
    conf.cc.defines << "MRBC_TASK_SCHEDULER_HOOK=1"
  end
end
