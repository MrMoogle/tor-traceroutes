#!/bin/bash

#--------------------------------------------------------------
# Purpose: Given output of tor_getHighestBWNodes.py, prints out
#		   ASes with highest BW. 
# Execution: bash processRelays.sh input.txt
# Output: Sorted list of ASes and their respective BW
#--------------------------------------------------------------

# Performs AS lookup of each IP address
while read line
do
	IP=`echo $line | cut -f1 -d" "`
	BW=`echo $line | cut -f2 -d" "`
	AS=`whois -h whois.cymru.com " -v $IP" | tail -1 | awk '{print $1}'` 
	echo "$AS $BW" >> temp.txt
done < $1 


awk '{ amount[$1] += $2 }
 END { for (name in amount)
 print name, amount[name]
 }' temp.txt | sort -k2 -n 

rm temp.txt

