#!/bin/python

import xml.etree.ElementTree as ET
import os

tree = ET.parse("Desktop/bugbounty/bpost/nmap_test.xml")

root = tree.getroot()

ip_ports = {}

for item in root.findall("./host"):
	hostname = item.find('./hostnames/hostname').attrib['name']
	print(hostname)
	ports = []
	for port in item.findall('./ports/port'):
		ports.append(port.attrib['portid'])
	ip_ports[hostname] = ','.join(ports)

for ip, ports in ip_ports.items():
	print("nmap -T4 -A -p{0} {1} -oN {1}-nmap.txt".format(ports, ip))
