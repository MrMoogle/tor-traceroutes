#!/bin/bash
#--------------------------------------------------------------
# Purpose: Translates hostnames to AS numbers 
# Execution: 
# Author: Oscar Li
#--------------------------------------------------------------

while read IP
do
	#IP="`dig +short $line`" 
	AS="`whois -h whois.cymru.com " -v $IP" | tail -1 | cut -f1 -d" "`"

	echo -e "$AS"
done < $1