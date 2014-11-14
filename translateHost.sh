#!/bin/bash
#--------------------------------------------------------------
# Purpose: Translates hostnames to AS numbers 
# Execution: 
# Author: Oscar Li
#--------------------------------------------------------------

while read line
do
	IP=`dig +short line` 
	AS=`whois -h whois.cymru.com " -v $IP" | sed -n 2p | cut -f1 -d" "`

done < $1