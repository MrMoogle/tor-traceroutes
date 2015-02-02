#!/bin/bash
#--------------------------------------------------------------
# Purpose: Converts traceroute data to CSV format 
# Execution: bash convertToCSV.sh <traceroutes folder name> > output
# Author: Oscar Li
#--------------------------------------------------------------

CURR_DIR=`pwd`

# Takes traceroute file and inserts it into DB 
function convert
{
	srcIP=`sed -n 2p < "$1" | cut -d "(" -f2 | cut -d ")" -f1` 
	if [ "$srcAS" = "*" ];
	then
		srcAS="AS"`whois -h whois.cymru.com " -v $srcIP" | tail -1 | cut -f1 -d" "`
	else 
		srcAS=`sed -n 2p < "$1" | cut -d "[" -f2 | cut -d "]" -f1`
	fi

	destIP=`echo $1 | awk -F"/" '{print $NF}' | cut -f1 -d "("`
	destAS="AS"`whois -h whois.cymru.com " -v $destIP" | tail -1 | cut -f1 -d" "`
	tstamp=`echo $1 | cut -d "(" -f2 | cut -d ")" -f1`
	path=`cat "$1"`

	echo $path | grep -o '\[[AS[0-9\/]*]*\]' | awk '!x[$0]++' > ~/tempCSV.txt
	aspath=`cat ~/tempCSV.txt` 
	numases=`wc -l < ~/tempCSV.txt | tr -d " \t\n\r"` 

	# A traceroute is invalid if it has more than 2 routers that timed out
	valid="true"
	if [ `grep -o "\* \* \*" "$1" | wc -l` -ge 2 ]; 
	then 
		valid="false"
	fi 

	# Creates CSV entry
	entry="$tstamp~$srcIP~$srcAS~$destIP~$destAS~$path~$aspath~$numases~$type~$valid"

	# For debug
	# echo "$1"
	# echo "HOST: $host"
	# echo "srcIP: $srcIP"
	# echo "srcAS: $srcAS"
	# echo "destIP: $destIP"
	# echo "destAS: $destAS"
	# echo "aspath: $aspath"
	# echo "numases: $numases"
	# echo "tstamp: $tstamp"
	# echo "valid: $valid"
	# echo "path: $path"
}

cd $1

type="Entry"
if [[ $1 == *exit* ]];
then
	type="Exit"
fi

for host in *
do
	cd $host 
	for traceroute in * 
	do 
		# convert "$CURR_DIR/$1/$host/$traceroute" 
		convert "$1/$host/$traceroute"
		echo "$entry" | sed ':a;N;$!ba;s/\n/\\n/g'
	done

	cd ..
	# rm -rf $host
done

cd ..
# rmdir "$1"