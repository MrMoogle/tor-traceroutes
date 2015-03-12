#!/bin/bash

rm -rf entryResults exitResults entryExitResults temp
rm entry.csv exit.csv entryExit.csv 

mkdir entryResults exitResults entryExitResults temp

# Prevent accidental DDOS
shuf as_ip_entryRelays.txt > rand_entry.txt
shuf as_ip_exitRelays.txt > rand_exit.txt  
shuf as_ip_entryExitRelays.txt > rand_entryExit.txt

srcAS=`awk '{print $1}' info.txt`
srcIP=`awk '{print $2}' info.txt`

function convert # (filepath, destIP, destAS, type) # 
{
	filePath=$1
	path=`cat $filePath`
	file=`basename $1`
	destIP=$2
	destAS="AS"$3
	type=$4
	tstamp=`date +%m-%d-%y\ %k:%M`

	# Extracts AS level path
	echo "begin" > temp/"$file"
	tail -n +2 "$filePath" | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+" >> temp/"$file"
	echo "end" >> temp/"$file"
	aspath=`nc whois.cymru.com 43 < temp/"$file" | awk '{print $1}' | awk '!x[$0]++' | tail -n +2 | grep -o "[0-9]\+" | sed 's/$/]/' | sed 's/^/[AS/'`
	rm temp/"$file"

	numases=`echo "$aspath" | wc -l | tr -d " \t\n\r"` 

	# A traceroute is invalid if it has more than 2 routers that timed out
	valid="true"
	if [ `grep -o "\* \* \*" "$filePath" | wc -l` -ge 3 ]; 
	then 
		valid="false"
	fi 

	echo "$tstamp~$srcIP~$srcAS~$destIP~$destAS~$path~$aspath~$numases~$type~$valid" | sed ':a;N;$!ba;s/\n/\\n/g'
}

# Performs traceroute to each Tor entry guard
while read line 
do 
	entryAS=`echo $line | awk '{print $1}'`
	entryIP=`echo $line | awk '{print $2}'`

	traceroute $entryIP > entryResults/"entry_$entryIP"
	convert entryResults/"entry_$entryIP" $entryIP $entryAS Entry >> entry.csv
done < rand_entry.txt &

# Performs traceroute to each Tor exit guard
while read line     
do 
	exitAS=`echo $line | awk '{print $1}'`
	exitIP=`echo $line | awk '{print $2}'`

	traceroute $exitIP > exitResults/"exit_$exitIP"
	convert exitResults/"exit_$exitIP" $exitIP $exitAS Exit >> exit.csv 
done < rand_exit.txt &

# Performs traceroute to each Tor entry/exit guard
while read line       
do 
	entryExitAS=`echo $line | awk '{print $1}'`
	entryExitIP=`echo $line | awk '{print $2}'`

	traceroute $entryExitIP > entryExitResults/"entryExit_$entryExitIP"
	convert entryExitResults/"entryExit_$entryExitIP" $entryExitIP $entryExitAS Both >> entryExit.csv
done < rand_entryExit.txt &