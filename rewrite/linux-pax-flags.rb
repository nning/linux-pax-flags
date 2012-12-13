#!/usr/bin/env ruby

require 'getoptlong'
require 'singleton'
require 'yaml'

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
      (old + new).uniq if old.is_a? Array
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
  puts <<EOF
#{File.basename($0)} [options] [configs]

    -h, --help       This help.
    -p, --prepend    Do not change anything.
    -y, --yes        Non-interactive mode. Assume yes on questions.

EOF
  exit 1
end

options = GetoptLong.new(
  ['--help',    '-h', GetoptLong::NO_ARGUMENT],
  ['--prepend', '-p', GetoptLong::NO_ARGUMENT],
  ['--yes',     '-y', GetoptLong::NO_ARGUMENT],
)

options.each do |option, argument|
  case option
    when '--help'
      usage
    when '--force'
      force = true
    when '--prepend'
      prepend = true
  end
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

config.each do |flags, paths|
  paths.each do |path|
    if path.is_a? String and File.exists? path
      puts ' * ' + path
    end
  end
end

puts
puts 'Continue writing PaX headers? [Y/n]'

a = readline.chomp.downcase
exit if a.downcase != 'y' unless a.empty?
