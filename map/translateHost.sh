#!/bin/bash
#--------------------------------------------------------------
# Purpose: Translates hostnames to AS numbers 
# Execution: 
# Author: Oscar Li
#--------------------------------------------------------------

while read line
do
	IP="`dig +short $line`" 
	AS="`whois -h whois.cymru.com " -v $IP" | tail -1 | cut -f1 -d" "`"

	echo -e "$line \t $IP \t $AS"
done < $1