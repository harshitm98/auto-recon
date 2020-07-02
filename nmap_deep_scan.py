#!/bin/python

import xml.etree.ElementTree as ET
import os
import sys

verbosity = False
file_path = ""

def extract_ip_and_ports(file_path):
	tree = ET.parse(file_path)
	root = tree.getroot()

	ip_ports = {}

	for item in root.findall("./host"):
		hostname = item.find('./hostnames/hostname').attrib['name']
		ports = []
		for port in item.findall('./ports/port'):
			ports.append(port.attrib['portid'])
		ip_ports[hostname] = ','.join(ports)

	for ip, ports in ip_ports.items():
		print("Running for ip : {} and ports : {}".format(ip, ports))
		if verbosity:
			os.system("nmap -T4 -A -p{0} {1} -oN {1}-nmap.txt".format(ports, ip))
		else:
			os.system("nmap -T4 -A -p{0} {1} -oN {1}-nmap.txt > /dev/null".format(ports, ip))

if __name__ == '__main__':
	if len(sys.argv) > 1:
		args = sys.argv[1:]
		if '-i' in args:
			file_path = args[args.index('-i') + 1]
		if '-v' in args:
			verbosity = True
		if file_path != "":
			extract_ip_and_ports(file_path)