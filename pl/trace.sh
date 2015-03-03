#!/bin/bash

rm -rf entryResults exitResults entryExitResults

mkdir entryResults exitResults entryExitResults

# Prevent accidental DDOS
shuf entryRelays.txt > rand_entry.txt
shuf exitRelays.txt > rand_exit.txt  
shuf entryExitRelays.txt > rand_entryExit.txt

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
	tstamp=`date +%m-%d-%y-%k:%M`
	FILENAME=$line"($tstamp)"    
	traceroute $line > exitResults/"$FILENAME"
done < rand_exit.txt &

# Performs traceroute to each Tor entry/exit guard
while read line           
do 
	tstamp=`date +%m-%d-%y-%k:%M`
	FILENAME=$line"($tstamp)"    
	traceroute $line > entryExitResults/"$FILENAME"
done < rand_entryExit.txt &
