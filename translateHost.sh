#!/bin/bash
#--------------------------------------------------------------
# Purpose: Translates hostnames to AS numbers 
# Execution: 
# Author: Oscar Li
#--------------------------------------------------------------

while read line
do
	IP="`dig +short $line`" 
	AS="`whois -h whois.cymru.com " -v $IP" | sed -n 2p | cut -f1 -d" "`"
	# echo "$line '\t' $IP '\t' $AS"

	echo -e "$line \t $IP \t $AS"
	# echo $AS
	# echo 
done < $1