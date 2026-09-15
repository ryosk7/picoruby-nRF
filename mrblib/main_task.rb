require 'machine'
require "watchdog"
Watchdog.disable
require "shell"
require "editor"

begin
  STDIN.echo = false
  puts "Initializing FLASH disk as the root volume... "
  Shell.setup_root_volume(:flash, label: 'storage')
  Shell.setup_system_files
  # A board command, so it is installed by the board rather than shipped
  # in picoruby-shell's executables: entering the bootloader depends on
  # which bootloader is flashed. Written once -- rewriting it every boot
  # would be a flash erase per power-on.
  unless File.file?("/bin/dfu")
    File.open("/bin/dfu", "w") do |f|
      f.puts "# Reboot into the UF2 bootloader. The NRF52BOOT volume appears;"
      f.puts "# copy a .uf2 onto it. Returns to this firmware if USB does not"
      f.puts "# enumerate within 3 seconds."
      f.puts "puts 'Rebooting into the UF2 bootloader...'"
      f.puts "Machine.reset_to_bootloader"
    end
  end
  puts "Available"

  shell = Shell.new(clean: true)
  puts "Starting shell...\n\n"
  shell.show_logo
  shell.start
rescue => e
  puts "#{e.message} (#{e.class})"

  loop do
    Machine.delay_ms 10
  end
end
