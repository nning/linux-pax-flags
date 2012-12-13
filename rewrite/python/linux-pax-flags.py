#!/usr/bin/env python

import configparser
import glob
import os.path
import subprocess


def read_config():
	"""
	Read all config files from /usr/share/linux-pax-flags and /etc/pax-flags and
	return a dictionary.
	"""

	paths = glob.glob('/usr/share/linux-pax-flags/*.conf')
	paths.extend(glob.glob('/etc/pax-flags/*.conf'))

	cp = configparser.ConfigParser()
	cp.read(paths)

	config = {}

	for section in cp.sections():
		if cp.has_option(section, 'Paths'):
			if not section in config:
				config[section] = []

			paths = filter(None, cp.get(section, 'Paths').split("\n"))

			config[section].extend(paths)

		if cp.has_option(section, 'Path'):
			path  = cp.get(section, 'Path')
			flags = cp.get(section, 'Flags')

			if not flags in config:
				config[flags] = []

			config[flags].append(path)

			config[path] = [
				cp.get(section, 'PreCommand'),
				cp.get(section, 'PostCommand')
			]

	return config


def main():
	config = read_config()

	for section in config:
		for path in config[section]:
			if os.path.exists(path):
				#if path in config:
				#	subprocess.call(config[path][0].split(' '))
				#subprocess.call(['paxctl', '-' + section, path])
				print(section + ' ' + path)
				#if path in config:
				#	subprocess.call(config[path][-1].split(' '))


if __name__ == '__main__':
	main()
