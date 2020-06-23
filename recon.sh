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

## Find subdomains using 

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


## Running nmap scan
echo "Running nmap scan..."
nmap -sn -Pn -n -iL all_subdomains.txt -oG hosts_up.txt > /dev/null
awk -F" " '{print $2}' hosts_up.txt | sort -u | grep -v Nmap > hosts_up_cleaned.txt
nmap -T4 -iL hosts_up_cleaned.txt -oN nmap_scan.txt > /dev/null

# OR to run for all ports comment the nmap command above and use the command below
# nmap -iL hosts_up_cleaned.txt -p- -oN nmap_scan.txt


