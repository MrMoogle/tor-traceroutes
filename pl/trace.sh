#!/bin/bash

mkdir entryResults
mkdir exitResults

# Prevent accidental DDOS
shuf entryNodes.txt > rand_entry.txt
shuf exitNodes.txt > rand_exit.txt  

# Performs traceroute to each Tor entry guard
while read line           
do 
	DATE=`date +%m-%d-%y-%k:%M`
	FILENAME=$line"($DATE)"    
	traceroute -A $line > entryResults/"$FILENAME"
done < rand_entry.txt &

# Performs traceroute to each Tor exit guard
while read line           
do 
	DATE=`date +%m-%d-%y-%k:%M`
	FILENAME=$line"($DATE)"    
	traceroute -A $line > exitResults/"$FILENAME"
done < rand_exit.txt &