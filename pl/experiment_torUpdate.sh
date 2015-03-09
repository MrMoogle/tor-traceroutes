#!/bin/bash

#--------------------------------------------------------------
# Purpose: Updates list of Tor entry/exit relays in PL nodes
# Execution: nohup bash experiment_torUpdate.sh & 
# Author: Oscar Li
# Notes: Tor must be running 
#--------------------------------------------------------------
cd

# Updates list of entry relays
python ~/tor-traceroutes/tor/tor_getEntryRelays.py ~/backup/entryRelays.txt
awk '!x[$0]++' ~/backup/entryRelays.txt > ~/backup/temp_entryRelays.txt
mv ~/backup/temp_entryRelays.txt ~/backup/entryRelays.txt

# Updates list of exit relays
python ~/tor-traceroutes/tor/tor_getExitRelays.py ~/backup/exitRelays.txt
awk '!x[$0]++' ~/backup/exitRelays.txt > ~/backup/temp_exitRelays.txt
mv ~/backup/temp_exitRelays.txt ~/backup/exitRelays.txt

# Updates list of entry/exit relays
python ~/tor-traceroutes/tor/tor_getEntryExitRelays.py ~/backup/entryExitRelays.txt
awk '!x[$0]++' ~/backup/entryExitRelays.txt > ~/backup/temp_entryExitRelays.txt
mv ~/backup/temp_entryExitRelays.txt ~/backup/entryExitRelays.txt

# Copies list of Tor entry/exit relays to PL nodes 
while read plNode           
do
	echo $plNode
 	scp -o BatchMode=yes ConnectTimeout=10 ~/backup/exitRelays.txt ~/backup/entryRelays.txt ~/backup/entryExitRelays.txt princeton_oscar@$plNode:. &
 	sleep 0.5
done < backup/allNodes.txt