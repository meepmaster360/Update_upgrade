#!/bin/bash
# Author: meepmaster
# Date: 19-04-2022
# Description: Update Upgrade


# Color variables 

RED="\033[1;31m"
GREEN="\033[1;32m"
NOCOLOR="\033[0m"

# Time variable

RIGHT_NOW=$(date +"%x %r %z")
TIME_STAMP="Updated $RIGHT_NOW by $USER"

# User root check

function user() {
	if [ $(id -u) != "0" ];then
		echo " Please run this script with root user!"
		exit 1
	fi
}

# Internet connection check

function connect() {
	ping -c 1 -w 3 google.com > /dev/null 2>&1
	if [ "$?" != 0 ];then
		echo " This script needs an active internet connection!"
		exit 1
	fi
}

# Update Upgrade Cleaning

function update_upgrade () {
	# System update/upgrade
	echo -e "\n${GREEN}Starting Update && Upgrade.${NOCOLOR}";sleep 1
	echo
	sudo dpkg --configure -a
	sudo apt-get install -f
	sudo apt-get --fix-broken install -y
	sudo apt update --fix-missing
	sudo apt-get upgrade -y
	sudo apt full-upgrade -y
	sudo apt-get dist-upgrade -y
	echo
	echo -e "${GREEN}Update and Upgrade finished.${NOCOLOR}";sleep 1

	# System cleaning
	echo -e "\n${GREEN}Starting Cleaning.${NOCOLOR}";sleep 1
	echo
	sudo apt-get --purge autoremove
	sudo apt-get autoclean
	sudo apt-get clean
	echo
	echo -e "\n${GREEN}Cleaning finished.${NOCOLOR}";sleep 1
	echo
	echo -e "${GREEN}$TIME_STAMP ${NOCOLOR}";sleep 1
	echo
	echo -e "${GREEN}Be light, be Yourself...${NOCOLOR}"
    echo
    echo
}

# Call funtions

user
connect
update_upgrade
