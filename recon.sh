#!/bin/bash
# Created by Harshit Maheshwari (@fake_batman_)

SUBLISTER_DIRECTORY_PATH="/opt/Sublist3r"

## Take inputs
while getopts ":o:i:" opt; do
  case $opt in
    o) OUTPUT_PATH="$OPTARG"
    ;;
    i) FILE_INPUT_PATH="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

## Creating the recon_output directory
if [ -e ./recon_output ];
then
	rm -rf ./recon_output
fi
mkdir recon_output
cd recon_output


## Create a final subdomains list (*.example.com -> example.com)
cat $FILE_INPUT_PATH | cut -c3- > final_domains.txt
echo "Created final_domains.txt"

## Creating a directory for secondlevel subdomains
if [ -e ./secondlevel ];
then
	rm -rf ./secondlevel
fi
mkdir secondlevel

## Find subdomains using sublist3r
for DOMAIN in $(cat final_domains.txt);
do 
	eval "$SUBLISTER_DIRECTORY_PATH/sublist3r.py -d $DOMAIN -o secondlevel/${DOMAIN}-subdomain.txt > /dev/null"
	cat secondlevel/${DOMAIN}-subdomain.txt >> all_second_level_subdomains.txt
	echo "Completed ${DOMAIN}..."
	# rm secondlevel/${DOMAIN}-subdomain.txt # remove this line if you need indiviual files for each subdomain
done

## Find subdomains using crt.sh
for DOMAIN in $(cat final_domains.txt);
do
	curl -s https://crt.sh/?Identity=%.$DOMAIN grep ">*.$DOMAIN" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$DOMAIN" | sort -u | awk 'NF' >> all_second_level_subdomains.txt
done

## Find subdomians using certspotter

for DOMAIN in $(cat final_domains.txt);
do
	curl -s https://certspotter.com/api/v0/certs\?domain\=$DOMAIN | jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u | grep $DOMAIN >> all_second_level_subdomains.txt
done

## Find subdomains using recon-ng [TODO]

## Keeping only unique subdomains
cat all_second_level_subdomains.txt | sort -u > all_second_level_subdomains_cleaned.txt

## Finding third-level subdomains

#if [ -e ./thirdlevel ];
#then
#	rm -rf ./thirdlevel
#fi
#mkdir thirdlevel

#
#for DOMAIN in $(cat all_second_level_subdomains_cleaned.txt);
#do 
#	eval "$SUBLISTER_DIRECTORY_PATH/sublist3r.py -d $DOMAIN -o thirdlevel/${DOMAIN}-subdomain.txt > /dev/null"
#	cat thirdlevel/${DOMAIN}-subdomain.txt >> all_thirdlevel_subdomains.txt
#	echo "Completed ${DOMAIN}..."
#	# rm thirdlevel/${DOMAIN}-subdomain.txt # remove this line if you need indiviual files for each subdomain
#done
#

## Creating a final list
cat final_domains.txt >> all_subdomains.txt
cat all_second_level_subdomains_cleaned.txt >> all_subdomains.txt 
#cat all_thirdlevel_subdomains.txt >> all_subdomains.txt

## Cleaning files
rm all_second_level_subdomains.txt
#rm all_thirdlevel_subdomains.txt


## Checking for online domains
echo "Checking online domains..."
for DOMAIN in $(cat all_subdomains.txt);
do
  if ping -c 1 $DOMAIN &>/dev/null
  then
    echo "$DOMAIN" >> domains_up.txt
  fi
done

## Running nmap scans on online domains
echo "Running nmap scan on online domains"
nmap -T4 -iL domains_up.txt -oN nmap_scan.txt -oX nmap_scan.xml > /dev/null

# OR to run for all ports comment the nmap command above and use the command below
# nmap -T4 -iL hosts_up_cleaned.txt -p- -oN nmap_scan.txt


