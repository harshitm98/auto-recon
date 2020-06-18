#!/bin/python

with open("nmap.txt") as f:
	nmap_lines = f.read()


SEARCH_STRING = "Nmap scan report for "


while nmap_lines.find(SEARCH_STRING) != -1:
	
	ip = nmap[nmap_lines.find(SEARCH_STRING) + len(SEARCH_STRING):
