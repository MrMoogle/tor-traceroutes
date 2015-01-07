#!/bin/bash

#--------------------------------------------------------------
# Purpose: Maps ASes to IP addresses 
# Execution: bash mapASToIP.sh <IP to AS> <List of ASes>
# Author: Oscar Li
#--------------------------------------------------------------

while read line 
do 
	grep "$line" $1 | head -1 | cut -f1 -d"/"
done < $2