#!/bin/bash
# Created by Harshit Maheshwari (@fake_batman_)

SUBLISTER_DIRECTORY_PATH="/opt/Sublist3r"

## Creating the output directory
if [ -e ./output ];
then
	rm -rf ./output
fi
mkdir output
cd output


## Create a final subdomains list (*.example.com -> example.com)
cat ../provided_subdomains.txt | cut -c3- > final_subdomains.txt
echo "Created final_subdomains.txt"

## Find subdomains using sublist3r
if [ -e ./secondlevel ];
then
	rm -rf ./secondlevel
fi
mkdir secondlevel


for DOMAIN in $(cat final_subdomains.txt);
do 
	eval "$SUBLISTER_DIRECTORY_PATH/sublist3r.py -d $DOMAIN -o secondlevel/${DOMAIN}-subdomain.txt > /dev/null"
	cat secondlevel/${DOMAIN}-subdomain.txt >> all_subdomain.txt
	echo "Completed ${DOMAIN}..."
	# rm secondlevel/${DOMAIN}-subdomain.txt # remove this line if you need indiviual files for each subdomain
done

## Find subdomains using crt.sh

## Other ways of finding subdomains using ... 

## Finding third-level subdomains
cat all_subdomain.txt | awk '/(\w+\.\w+\.\w+)$/{print $0}' | sort -u > all_subdomain.txt

if [ -e ./thirdlevel ];
then
	rm -rf ./thirdlevel
fi
mkdir thirdlevel


for DOMAIN in $(cat all_subdomain.txt);
do 
	eval "$SUBLISTER_DIRECTORY_PATH/sublist3r.py -d $DOMAIN -o thirdlevel/${DOMAIN}-subdomain.txt > /dev/null"
	cat thirdlevel/${DOMAIN}-subdomain.txt >> all_thirdlevel_subdomains.txt
	echo "Completed ${DOMAIN}..."
	# rm thirdlevel/${DOMAIN}-subdomain.txt # remove this line if you need indiviual files for each subdomain
done

## Running nmap scan
echo "Running nmap scan..."
nmap -sn -Pn -n -iL all_thirdlevel_subdomains.txt -oG out.txt > /dev/null
awk -F" " '{print $2}' out.txt > outnew.txt
nmap -iL outnew.txt -oN final_nmap.txt > /dev/null

# OR to run for all ports comment the nmap command above and use the command below
# nmap -iL outnew.txt -p- -oN final_nmap.txt


