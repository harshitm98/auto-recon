#!/bin/python

import xml.etree.ElementTree as ET
import os
import sys

verbosity = False
file_path = ""
attention_file_path = ""

def extract_ip_and_ports(file_path, attention_file_path=""):
	if attention_file_path != "":
		with open(attention_file_path, "r") as f:
			attention_domains = f.read().split('\n')
	tree = ET.parse(file_path)
	root = tree.getroot()

	ip_ports = {}

	for item in root.findall("./host"):
		hostname = item.find('./hostnames/hostname').attrib['name']
		if hostname not in attention_domains:
			continue
		ports = []
		for port in item.findall('./ports/port'):
			ports.append(port.attrib['portid'])
		ip_ports[hostname] = ','.join(ports)

	## TODO: Check if directory already exists
	os.system("mkdir nmap")
	## TODO: Run this loop in parallel
	for ip, ports in ip_ports.items():
		print("Running for ip : {} and ports : {}".format(ip, ports))
		if verbosity:
			os.system("nmap -T4 -A -p{0} {1} -oN nmap/{1}-nmap.txt".format(ports, ip))
		else:
			os.system("nmap -T4 -A -p{0} {1} -oN nmap/{1}-nmap.txt > /dev/null".format(ports, ip))

if __name__ == '__main__':
	if len(sys.argv) > 1:
		args = sys.argv[1:]
		if '-f' in args:
			file_path = args[args.index('-f') + 1]
		if '-v' in args:
			verbosity = True
		if '-a' in args:
			attention_file_path = args[args.index('-a') + 1]
		if file_path != "":
			if attention_file_path != "":
				extract_ip_and_ports(file_path, attention_file_path)
			else:
				extract_ip_and_ports(file_path)