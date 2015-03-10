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
	scp -o ConnectTimeout=5 -r princeton_oscar@$1:entryResults $ENTRY_DIRNAME/$1 2> /dev/null 
  	scp -o ConnectTimeout=5 -r princeton_oscar@$1:exitResults $EXIT_DIRNAME/$1 2> /dev/null 
  	scp -o ConnectTimeout=5 -r princeton_oscar@$1:entryExitResults $ENTRYEXIT_DIRNAME/$1 2> /dev/null 
	
	ssh -n princeton_oscar@$1 "nohup bash trace.sh > /dev/null 2>&1"
}

cd

# Copies traceroute data back to local machine
while read PLNode           
do
 	nodeOp $PLNode &
 	sleep 15
 	echo $PLNode >> logs/experiment"($DATE)"
done < backup/allNodes.txt

# Inserts into DB
#bash tor-traceroutes/db/insertIntoDB.sh $ENTRY_DIRNAME &
#bash tor-traceroutes/db/insertIntoDB.sh $EXIT_DIRNAME & 