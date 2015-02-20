#!/bin/bash

rm -rf entryResults exitResults

mkdir entryResults exitResults

# Prevent accidental DDOS
shuf entryRelays.txt > rand_entry.txt
shuf exitRelays.txt > rand_exit.txt  

# Performs traceroute to each Tor entry guard
while read line           
do 
	tstamp=`date +%m-%d-%y\ %k:%M`
	FILENAME=$line"($tstamp)"    
	traceroute $line > entryResults/"$FILENAME"
done < rand_entry.txt &

# Performs traceroute to each Tor exit guard
while read line           
do 
	DATE=`date +%m-%d-%y-%k:%M`
	FILENAME=$line"($DATE)"    
	traceroute $line > exitResults/"$FILENAME"
done < rand_exit.txt &