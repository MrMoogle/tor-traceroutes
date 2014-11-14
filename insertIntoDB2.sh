#!/bin/bash
#--------------------------------------------------------------
# Purpose: Inserts traceroute files into database
# Execution: bash insertIntoDb.sh <traceroutes folder name> 
# Author: Oscar Li
#--------------------------------------------------------------

# Takes traceroute file and inserts it into DB 
function insert
{
	srcIP=`sed -n 2p < "$1" | cut -d "(" -f2 | cut -d ")" -f1` 
	srcAS=`sed -n 2p < "$1" | cut -d "[" -f2 | cut -d "]" -f1`
	if [ "$srcAS" = "*" ];
	then
		srcAS="AS"`whois -h whois.cymru.com " -v $srcIP" | sed -n 4p | cut -f1 -d" "`
	fi

	destIP=`echo $1 | cut -f1 -d "("`
	destAS="AS"`whois -h whois.cymru.com " -v $destIP" | sed -n 4p | cut -f1 -d" "`
	tstamp=`echo $1 | cut -d "(" -f2 | cut -d ")" -f1`
	path=`cat "$1"`
	
	# A traceroute seis invalid if it has more than 2 routers that timed out
	valid="true"
	if [ `grep -o "\* \* \*" "$1" | wc -l` -ge 2 ]; 
	then 
		valid="false"
	fi 

	# If traceroute is completed, retrieves destAS from traceroute. Otherwise,
	# retrieves destAS by querying whois.cymru.com. 
	lastLine=`tail -1 "$1" | grep "*"`
	if [[ "$lastLine" ]];
	then
		valid="false" 
		destAS="AS"`whois -h whois.cymru.com " -v $destIP" | sed -n 4p | cut -f1 -d" "`
	else
		destAS=`tail -1 "$1" | cut -d "[" -f2 | cut -d "]" -f1`
	fi

	# Inserts into database
	query="INSERT INTO paths (tstamp, srcip, srcas, destip, destas, path, type, valid) \
		   VALUES (to_timestamp('$tstamp', 'MM-DD-YY-HH24:MI'), \
		   		   '$srcIP', '$srcAS', '$destIP', '$destAS', '$path', '$type', $valid);"
	# psql -U oli -d postgres -w -c "$query"

	# #For debug
	echo "HOST: $host"
	echo "srcIP: $srcIP"
	echo "srcAS: $srcAS"
	echo "destIP: $destIP"
	echo "destAS: $destAS"
	echo "tstamp: $tstamp"
	echo "valid: $valid"
	echo	
}

#cd $1
# e.g. entryResults/entryResults...
cd /mnt/external-drive/$1

type="Entry"
if [[ $1 == *exit* ]];
then
	type="Exit"
fi

touch /home/oli/logs/insertIntoDB2

for host in *
do
	cd $host 
	for traceroute in * 
	do 
		insert "/mnt/external-drive/$1/$host/$traceroute" &
		echo "$host:$traceroute" >> /home/oli/logs/insertIntoDB2 &  
	done

	cd ..
	sleep 15
	# rm -rf $host
done

cd ..
rmdir "$1"