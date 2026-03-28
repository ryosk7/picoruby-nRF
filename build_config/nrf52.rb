MRuby::CrossBuild.new("nrf52") do |conf|
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

  conf.cc.defines << "MRBC_TICK_UNIT=10"
  conf.cc.defines << "MRBC_TIMESLICE_TICK_COUNT=1"
  conf.cc.defines << "MRBC_NO_TIMER=1"
  conf.cc.defines << "MRBC_USE_FLOAT=2"
  conf.cc.defines << "PICORUBY_INT64"
  conf.cc.defines << "NDEBUG"

  conf.picoruby(alloc_libc: false)
  conf.gembox "minimum"
  conf.gembox "core"
  conf.gem core: "picoruby-shell"
  conf.gem core: "picoruby-watchdog"
end
