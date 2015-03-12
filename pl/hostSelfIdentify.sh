#!/bin/bash

#--------------------------------------------------------------
# Purpose: Generates a file "info.txt" with the host's IP address
# 	       and AS number.  
# Execution: bash hostSelfIdentify.sh 
# Author: Oscar Li
#--------------------------------------------------------------

IP=`curl -s http://whatismijnip.nl | cut -d " " -f 5`
AS=`traceroute -A $IP | tail -1 | cut -d "[" -f2 | cut -d "]" -f1` 

echo "$AS $IP" > info.txt 