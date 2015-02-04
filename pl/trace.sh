#!/bin/bash

mkdir entryResults
mkdir exitResults

# Prevent accidental DDOS
shuf entryNodes.txt > rand_entry.txt
shuf exitNodes.txt > rand_exit.txt  

# Performs traceroute to each Tor entry guard
while read line           
do 
	tstamp=`date +%m-%d-%y\ %k:%M`
	FILENAME=$line"($tstamp)"    
	traceroute -A $line > entryResults/"$FILENAME"

done < rand_entry.txt &

# Performs traceroute to each Tor exit guard
while read line           
do 
	DATE=`date +%m-%d-%y-%k:%M`
	FILENAME=$line"($DATE)"    
	traceroute -A $line > exitResults/"$FILENAME"
done < rand_exit.txt &

# Converts to CSV 


#ifconfig | perl -nle 's/dr:(\S+)/print $1/e'