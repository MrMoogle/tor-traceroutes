#!/bin/bash

#--------------------------------------------------------------
# Purpose: The main shell script that runs the experiment
# Execution: nohup bash experiment.sh & 
# Author: Oscar Li
#--------------------------------------------------------------


# Creates the name of the directory that we copy to
DATE=`date +%m-%d-%y`
ENTRY_DIRNAME=entryResults"($DATE)"
EXIT_DIRNAME=exitResults"($DATE)"
mkdir $ENTRY_DIRNAME
mkdir $EXIT_DIRNAME

# Copies back the traceroute data, deletes it, and runs a new traceroute job
function nodeOp 
{
	scp -o ConnectTimeout=5 -r princeton_oli@$1:entryResults $ENTRY_DIRNAME/$1 2> /dev/null 
  scp -o ConnectTimeout=5 -r princeton_oli@$1:exitResults $EXIT_DIRNAME/$1 2> /dev/null 
	
	if [ -e "$DIRNAME"/$1 ];
	then
    scp exitNodes.txt princeton_oli@$1:.
    scp entryNodes.txt princeton_oli@$1:. 
    ssh -n princeton_oli@$1 "rm -rf entryResults && rm -rf exitResults && nohup bash trace.sh > /dev/null 2>&1"
	fi 
}

cd

# Gets most updated list of Tor entry guards
mv entryNodes.txt foo.txt
python scripts/tor_getEntryNodes.py foo.txt > entryNodes.txt
rm foo.txt

# Gets most updated list of Tor exit guards
mv exitNodes.txt foo.txt
python scripts/tor_getExitNodes.py foo.txt > exitNodes.txt
rm foo.txt

# Backup
cp entryNodes.txt backup/.
cp exitNodes.txt backup/.

# Gets list of active PL nodes
python scripts/retrieveActiveNodes.py > temp.txt
if ((`wc -l < temp.txt` > 0));
then
  sort temp.txt > nodes.txt
fi 
rm temp.txt

# Copies traceroute data back to local machine
while read line           
do
 	nodeOp $line &
 	sleep 15
 	echo $line >> output/output"($DATE)"
done < nodes.txt

# Inserts into database
nohup bash insertIntoDB.sh "$ENTRY_DIRNAME" &
nohup bash insertIntoDB.sh "$EXIT_DIRNAME" &