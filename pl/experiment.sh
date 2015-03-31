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
ENTRYEXIT_DIRNAME=entryExitResults"($DATE)"

mkdir $ENTRY_DIRNAME
mkdir $EXIT_DIRNAME
mkdir $ENTRYEXIT_DIRNAME

# Copies back the traceroute data, deletes it, and runs a new traceroute job
function nodeOp 
{
	scp -r -o BatchMode=yes -o ConnectTimeout=5 -r princeton_oscar@$1:entry.csv $ENTRY_DIRNAME/$1 2> /dev/null
  	scp -r -o BatchMode=yes -o ConnectTimeout=5 -r princeton_oscar@$1:exit.csv $EXIT_DIRNAME/$1 2> /dev/null
  	scp -r -o BatchMode=yes -o ConnectTimeout=5 -r princeton_oscar@$1:entryExit.csv $ENTRYEXIT_DIRNAME/$1 2> /dev/null
	
	ssh -n -o BatchMode=yes -o ConnectTimeout=5 princeton_oscar@$1 "nohup bash trace.sh > /dev/null 2>&1"
}

cd

# For logging progress
touch logs/experiment$DATE

# Copies traceroute data back to local machine
# Do not try to parallelize
while read PLNode           
do
 	nodeOp $PLNode
 	sleep 1
 	echo $PLNode >> logs/experiment$DATE
done < ~/backup/allNodes.txt

# Inserts data into database 
bash tor-traceroutes/db/insertIntoDB.sh $ENTRY_DIRNAME
bash tor-traceroutes/db/insertIntoDB.sh $EXIT_DIRNAME
bash tor-traceroutes/db/insertIntoDB.sh $ENTRYEXIT_DIRNAME