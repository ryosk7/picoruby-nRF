require 'machine'
require "watchdog"
Watchdog.disable
require "shell"

STDIN = IO.new
STDOUT = IO.new

begin
  STDIN.echo = false

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
