require 'machine'
require "watchdog"
Watchdog.disable
require "shell"
require "editor"

begin
  STDIN.echo = false

  # Temporary nRF52 workaround: ANSI cursor-position probing over USB CDC is
  # not stable yet, so shell/editor uses a fixed terminal size.
  module Editor
    def self.get_screen_size
      [24, 80]
    end
  end

  shell = Shell.new(clean: false)
  puts "Starting shell...\n\n"
  shell.show_logo
  shell.start
rescue => e
  puts "#{e.message} (#{e.class})"

  loop do
    Machine.delay_ms 10
  end
end
