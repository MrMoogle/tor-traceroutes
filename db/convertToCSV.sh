#!/bin/bash
#--------------------------------------------------------------
# Purpose: Converts traceroute data to CSV format 
# Execution: bash convertToCSV.sh <traceroutes folder name> > output
# Author: Oscar Li
# Notes: Bash must be version 4 or above
#--------------------------------------------------------------

CURR_DIR=`pwd`

# Maps IP addreses to ASes
declare -A ip_AS

cd $1

# Takes traceroute file and converts it to CSV format
function convert
{
	destIP=`echo $1 | awk -F"/" '{print $NF}' | cut -f1 -d "("`
	destAS="${ip_AS["$destIP"]}"

	if [ "$destAS" = "" ];
	then 
		destAS="AS"`whois -h whois.cymru.com " -v $destIP" | tail -1 | cut -f1 -d" "`
		ip_AS["$destIP"]="$destAS"
	fi 
	
	tstamp=`echo $1 | cut -d "(" -f2 | cut -d ")" -f1 | sed 's/-/ /3'`
	path=`cat "$1"`

	grep -o '\[[AS[0-9\/]*]*\]' "$1" | awk '!x[$0]++' > ~/tempCSV.txt
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

type="Entry"
if [[ $1 == *exit* ]];
then
	type="Exit"
fi

tstamp=`date +%m-%d-%y_%k:%M`

# For logging progress
touch "$CURR_DIR"/logs/"$type$tstamp"

for host in *
do
	echo $host >> "$CURR_DIR"/logs/"$type$tstamp"

	cd $host 

	# Finds srcIP and srcAS for host
	srcIP="`dig +short $host`" 
	traceroute=`ls -1 | head -1`
	srcAS=`sed -n 2p < "$traceroute" | cut -d "[" -f2 | cut -d "]" -f1`
	if [ "$srcAS" = "*" ];
	then
		srcAS="AS"`whois -h whois.cymru.com " -v $srcIP" | tail -1 | cut -f1 -d" "`
	fi

	for traceroute in * 
	do 
		convert "$CURR_DIR/$1/$host/$traceroute" 
		#convert "$1/$host/$traceroute"

		echo "$entry" | sed ':a;N;$!ba;s/\n/\\n/g'
	done

	cd ..
done

cd ..