#!/bin/bash

#--------------------------------------------------------------
# Purpose: Updates list of Tor entry/exit relays in PL nodes
# Execution: nohup bash experiment_torUpdate.sh & 
# Author: Oscar Li
# Notes: Tor must be running 
#--------------------------------------------------------------

# Given a list of IP addresses, produces a two column file with
# IP addresses in the first column and ASes in the second column
function map 
{
	file=`basename $1`

	echo "begin" > "temp_$file"
	cat $1 >> "temp_$file"
	echo "end" >> "temp_$file"

	nc whois.cymru.com 43 < "temp_$file" | tail -n +2 | awk '{print $1 "\t" $3}'

	# cleanup 
	rm "temp_$file"
}

cd

# Updates list of entry relays
python ~/tor-traceroutes/tor/tor_getEntryRelays.py ~/backup/entryRelays.txt
awk '!x[$0]++' ~/backup/entryRelays.txt > ~/backup/temp_entryRelays.txt
mv ~/backup/temp_entryRelays.txt ~/backup/entryRelays.txt
map ~/backup/entryRelays.txt > ~/backup/as_ip_entryRelays.txt

# Updates list of exit relays
python ~/tor-traceroutes/tor/tor_getExitRelays.py ~/backup/exitRelays.txt
awk '!x[$0]++' ~/backup/exitRelays.txt > ~/backup/temp_exitRelays.txt
mv ~/backup/temp_exitRelays.txt ~/backup/exitRelays.txt
map ~/backup/exitRelays.txt > ~/backup/as_ip_exitRelays.txt

# Updates list of entry/exit relays
python ~/tor-traceroutes/tor/tor_getEntryExitRelays.py ~/backup/entryExitRelays.txt
awk '!x[$0]++' ~/backup/entryExitRelays.txt > ~/backup/temp_entryExitRelays.txt
mv ~/backup/temp_entryExitRelays.txt ~/backup/entryExitRelays.txt
map ~/backup/entryExitRelays.txt > ~/backup/as_ip_entryExitRelays.txt

# Copies list of Tor entry/exit relays to PL nodes 
while read plNode           
do
	echo $plNode
 	scp -o BatchMode=yes ConnectTimeout=10 ~/backup/as_ip_exitRelays.txt ~/backup/as_ip_entryRelays.txt ~/backup/as_ip_entryExitRelays.txt princeton_oscar@$plNode:. &
 	sleep 0.5
done < backup/allNodes.txt