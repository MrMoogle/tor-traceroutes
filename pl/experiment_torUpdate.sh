#!/bin/bash

#--------------------------------------------------------------
# Purpose: Updates list of Tor entry/exit relays in PL nodes
# Execution: nohup bash torRelaysUpdate.sh & 
# Author: Oscar Li
# Notes: Tor must be running 
#--------------------------------------------------------------
cd

# Gets most updated list of Tor entry guards
mv ~/backup/entryRelays.txt foo.txt
python ~/tor-traceroutes/tor/tor_getEntryNodes.py foo.txt > ~/backup/entryRelays.txt
rm foo.txt

# Gets most updated list of Tor exit guards
mv ~/backup/entryRelays.txt foo.txt
python ~/tor-traceroutes/tor/tor_getExitNodes.py foo.txt > ~/backup/exitRelays.txt
rm foo.txt

# Backup
cp ~/backup/entryRelays.txt ~/backup/oldEntryRelays.txt
cp ~/backup/exitRelays.txt ~/backup/oldExitRelays.txt

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
 	scp ~/backup/exitRelays.txt princeton_oscar@$plNode:.
 	scp ~/backup/entryRelays.txt princeton_oscar@$plNode:. 
done < nodes.txt