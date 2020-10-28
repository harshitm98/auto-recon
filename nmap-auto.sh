#!/bin/bash

## Take inputs
while getopts ":i:" opt; do
    case $opt in
        i) IP="$OPTARG"
        ;;
        \?) echo "Invalid option -$OPTARG" >&2
        ;;
    esac
done

## Make nmap directory
mkdir -p $PWD/nmap

## Nmap commands to be run

# SERVICE_SCAN="nmap -T4 -A $IP -p$PORTS -oA nmap/service-scan"
# VULN_SCAN="nmap -T4 --script vuln $IP -p$PORTS -oA nmap/vuln-scan"
# ALL_SCAN="nmap -T4 -p- $IP -oA nmap/all-scan"

# Running ALL_SCAN
echo ""
echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # #"
echo "#                    ALL_SCAN_TCP                     #"
echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # #"
echo ""
ALL_SCAN="nmap -p- --min-rate 10000 -vvv $IP -oA nmap/all-scan -Pn"
eval $ALL_SCAN

# Extracting ports
PORTS=""
EXTRACTED_PORTS=$(grep -oP '\d{1,5}/open' nmap/all-scan.gnmap)
for PORT in $(echo $EXTRACTED_PORTS);
do  
    PORTS="${PORTS},${PORT::-5}"
done
PORTS="${PORTS:1}"

# Running SERVICE_SCAN
echo ""
echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # #"
echo "#                    SERVICE_SCAN                     #"
echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # #"
echo ""
SERVICE_SCAN="nmap -T4 -A $IP -p${PORTS} -oA nmap/service-scan -Pn"
eval $SERVICE_SCAN

# Running VULN_SCAN
echo ""
echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # #"
echo "#                      VULN_SCAN                      #"
echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # #"
echo ""
VULN_SCAN="nmap -T4 --script vuln $IP -p$PORTS -oA nmap/vuln-scan -Pn"
eval $VULN_SCAN


