#!/bin/bash
#--------------------------------------------------------------
# Purpose: Inserts traceroute files into database
# Execution: bash insertIntoDb.sh <traceroutes folder name> 
# Author: Oscar Li
#--------------------------------------------------------------

CURR_DIR=`pwd`

# Maps IP addreses to ASes
declare -A ip_AS

# Takes traceroute file and inserts it into DB 
function insert
{
	file=$1

	destIP=`echo $1 | awk -F"/" '{print $NF}' | cut -f1 -d "("`
	destAS="${ip_AS["$destIP"]}"

	if [ "$destAS" = "" ];
	then 
		destAS="AS"`whois -h whois.cymru.com " -v $destIP" | tail -1 | cut -f1 -d" "`
		ip_AS["$destIP"]="$destAS"
	fi 
	
	tstamp=`echo $1 | cut -d "(" -f2 | cut -d ")" -f1 | sed 's/-/ /3'`
	path=`cat "$1"`

	# Extracts AS level path
	echo "begin" > "temp_$file"
	grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+" "$file" >> "temp_$file"
	echo "end" >> "temp_$file"
	aspath=`nc whois.cymru.com 43 < "temp_$file" | awk '{print $1}' | awk '!x[$0]++' | tail -n +2 | grep -o "[0-9]\+" | sed 's/$/]/' | sed 's/^/[AS/'`
	rm "temp_$file"

	numases=`echo "$aspath" | wc -l | tr -d " \t\n\r"` 

	# A traceroute is invalid if it has more than 2 routers that timed out
	valid="true"
	if [ `grep -o "\* \* \*" "$file" | wc -l` -ge 2 ]; 
	then 
		valid="false"
	fi 

	# Inserts into database
	query="INSERT INTO paths (tstamp, srcip, srcas, destip, destas, path, aspath, numases, type, valid) \
		   VALUES (to_timestamp('$tstamp', 'MM-DD-YY-HH24:MI'), \
		   		   '$srcIP', '$srcAS', '$destIP', '$destAS', '$path', '$aspath', $numases, '$type', $valid);"
	psql -U oli -d raptor -w -c "$query" &

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
	# echo "$path"
	# echo	
}

cd $1

# For some reason, we get these weird files that mess up the script. 
# This command deletes those files
find . -name "(*)" -exec rm '{}' \;

type="Entry"
if [[ $1 == *exit* ]];
then
	type="Exit"
fi

mkdir ~/data_raw/"$type"/"$1"

# For logging progress
touch "$CURR_DIR"/logs/"$1"

for host in *
do
	cd $host 

	# Finds srcIP and srcAS for host
	srcIP="`dig +short $host`" 
	traceroute=`ls -1 | head -1`
	srcAS=`sed -n 2p < "$traceroute" | cut -d "[" -f2 | cut -d "]" -f1`
	if [ "$srcAS" = "*" ];
	then
		srcAS="AS"`whois -h whois.cymru.com " -v $srcIP" | tail -1 | cut -f1 -d" "`
	fi

	# Doing this completely in parallel is a bad idea
	for traceroute in * 
	do 
		insert "$traceroute"
	done
	
	cd ..

	sleep 5
	echo $host >> "$CURR_DIR"/logs/"$1"
	rm -rf "$host" & 
done

cd ..

rmdir $1