#!/usr/bin/env ruby

require 'getoptlong'
require 'readline'
require 'singleton'
require 'yaml'

class Array
  # ["foo", {"foo" => 1}].cleanup => [{"foo" => 1}]
  # If the key in a Hash element of an Array is also present as an element of
  # the Array, delete the latter.
  def cleanup
    array = self.dup
    self.grep(Hash).map(&:keys).flatten.each do |x|
      array.delete x
    end
    array
  end
end

# Class handles configuration parameters.
class FlagsConfig < Hash
  # This is a singleton class.
  include Singleton

  # Merges a Hash or YAML file (containing a Hash) with itself.
  def load config
    if config.class == Hash
      merge! config
      return
    end

    unless config.nil?
      merge_yaml! config
    end
  end

  # Merge Config Hash with Hash in YAML file.
  def merge_yaml! path
    merge!(load_file path) do |key, old, new|
      (old + new).uniq.cleanup if old.is_a? Array and new.is_a? Array
    end
  end

  # Load YAML file and work around tabs not working for identation.
  def load_file path
    YAML.load open(path).read.gsub(/\t/, '   ')
  rescue Psych::SyntaxError => e
    print path, ':', e.message.split(':').last, "\n"
    exit 1
  end
end

def usage
  $stderr.puts <<EOF
#{File.basename($0)} [options] [configs]

    -h, --help       This help.
    -p, --prepend    Do not change anything.
    -y, --yes        Non-interactive mode. Assume yes on questions.

EOF
  exit 1
end

def each_entry config
  config.each do |flags, entries|
    entries.each do |entry|
      if entry.is_a? String
        pattern = entry
      elsif entry.is_a? Hash
        pattern = entry.keys.first
      end

      unless ENV['SUDO_USER'].nil?
        paths = File.expand_path pattern.gsub('~', '~' + ENV['SUDO_USER'])
      else
        paths = File.expand_path pattern
      end

      Dir.glob(paths).each do |path|
        yield flags, entry, pattern, path
      end
    end
  end
end

options = GetoptLong.new(
  ['--help',    '-h', GetoptLong::NO_ARGUMENT],
  ['--prepend', '-p', GetoptLong::NO_ARGUMENT],
  ['--yes',     '-y', GetoptLong::NO_ARGUMENT],
)

prepend = false
yes = false

begin
  options.each do |option, argument|
    case option
      when '--help'
        usage
      when '--prepend'
        prepend = true
      when '--yes'
        yes = true
    end
  end
rescue GetoptLong::InvalidOption => e
  usage
end

if Process.uid != 0
  $stderr << "Root privileges needed.\n"
  exit 1
end

config_paths = if ARGV.empty?
  ['/etc/pax-flags/*.conf', '/usr/share/linux-pax-flags/*.conf']
else
  ARGV
end

config = FlagsConfig.instance

config_paths.each do |path|
  Dir.glob(path).each do |file|
    config.load file
  end
end

puts <<EOF
Some programs do not work properly without deactivating some of the PaX
features. Please close all instances of them if you want to change the
configuration for the following binaries:
EOF

# TODO A binary which has pre_ and post_command configured does not have to be
#      shown here.
#      Also, it would be good to list changes seperated between binaries which
#      have to be terminated manually and those which have pre_ and
#      post_command.
each_entry config do |flags, entry, pattern, path|
  puts ' * ' + path if File.exists? path
end

puts
puts 'Continue writing PaX headers? [Y/n]'

$stdout.flush

unless yes
  a = Readline.readline.chomp.downcase
  exit 1 if a.downcase != 'y' unless a.empty?
end

each_entry config do |flags, entry, pattern, path|
  if File.exists? path
    e = entry[pattern]
    actions = %w(status start stop)
    start_again = false

    status = e['status']
    start  = e['start']
    stop   = e['stop']

    if e['type'] == 'systemd'
      name = e['systemd_name'] || File.basename(path)
      actions.each do |action|
        eval "#{action} = \"systemctl #{action} #{name}.service\""
      end
    end

    if entry.is_a? Hash
      if status and system(status + '> /dev/null')
        system stop unless prepend
        start_again = true if start
      end
    end

    `paxctl -c#{flags} "#{path}"` unless prepend
    print flags, ' ', path, "\n"

    system start unless prepend if start_again
  end
end
