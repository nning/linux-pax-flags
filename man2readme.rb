#!/usr/bin/env ruby
puts `cat #{ARGV[0]} | groff -mandoc -T utf8`.gsub(/./, '')
