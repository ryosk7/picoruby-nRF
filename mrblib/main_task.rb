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
