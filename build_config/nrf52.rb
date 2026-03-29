MRuby::CrossBuild.new("nrf52") do |conf|
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
  conf.cc.defines << "NDEBUG"

  conf.picoruby(alloc_libc: false)
  conf.gembox "minimum"
  conf.gembox "core"
  conf.gem core: "picoruby-gpio"
  conf.gem core: "picoruby-shell"
  conf.gem core: "picoruby-watchdog"
end
