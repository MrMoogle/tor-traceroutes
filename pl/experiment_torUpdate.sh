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

# Gets list of active PL nodes
python tor-traceroutes/pl/retrieveActiveNodes.py > temp.txt
if ((`wc -l < temp.txt` > 0));
then
  sort temp.txt > nodes.txt
fi 
rm temp.txt

# Copies list of Tor entry/exit relays to PL nodes 
while read plNode           
do
 	scp ~/backup/exitRelays.txt princeton_oscar@$plNode:. &
 	scp ~/backup/entryRelays.txt princeton_oscar@$plNode:. &
 	sleep 0.25
done < nodes.txt