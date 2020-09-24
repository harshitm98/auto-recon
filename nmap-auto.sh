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

# QUICK_SCAN="nmap -T4 $IP -oA nmap/quick-scan"
# DEEP_QUICK_SCAN="nmap -T4 -A $IP -p$PORTS -oA nmap/deep-quick-scan"
# VULN_QUICK_SCAN="nmap -T4 --script vuln $IP -p$PORTS -oA nmap/vuln-quick-scan"
# ALL_SCAN="nmap -T4 -p- $IP -oA nmap/all-scan"

# Running QUICK_SCAN
echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # #"
echo "#                     QUICK_SCAN                      #"
echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # #"
echo ""
QUICK_SCAN="nmap -T4 $IP -oA nmap/quick-scan -Pn"
eval $QUICK_SCAN


# Extracting ports
PORTS=""
EXTRACTED_PORTS=$(grep -oP '\d{1,5}/open' nmap/quick-scan.gnmap)
for PORT in $(echo $EXTRACTED_PORTS);
do  
    PORTS="${PORTS},${PORT::-5}"
done
PORTS="${PORTS:1}"

# Running DEEP_QUICK_SCAN
echo ""
echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # #"
echo "#                   DEEP_QUICK_SCAN                   #"
echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # #"
echo ""
DEEP_QUICK_SCAN="nmap -T4 -A $IP -p${PORTS} -oA nmap/deep-quick-scan -Pn"
eval $DEEP_QUICK_SCAN

# Running VULN_QUICK_SCAN
echo ""
echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # #"
echo "#                   VULN_QUICK_SCAN                   #"
echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # #"
echo ""
VULN_QUICK_SCAN="nmap -T4 --script vuln $IP -p$PORTS -oA nmap/vuln-quick-scan -Pn"
eval $VULN_QUICK_SCAN

# Running ALL_SCAN
echo ""
echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # #"
echo "#                      ALL_SCAN                       #"
echo "# # # # # # # # # # # # # # # # # # # # # # # # # # # #"
echo ""
ALL_SCAN="nmap -T4 -p- $IP -oA nmap/all-scan -Pn"
eval $ALL_SCAN
