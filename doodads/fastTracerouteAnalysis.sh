#!/bin/bash

#--------------------------------------------------------------
# Purpose: Extract AS paths from folder of fast traceroutes
# Exeuction: bash fastTracerouteAnalysis.sh <folder name>
# Output: paths.txt (each line is an AS path of a traceroute)
#--------------------------------------------------------------

cd $1

for traceroute in *
do
	ASpath=`cat "$traceroute" | tr -d '\n' | grep -o '\[AS[0-9]*\]' | awk '!x[$0]++'` 
	echo $ASpath >> paths.txt
done

cd ..
#rmdir "$1"


# cd ..
# mkdir $2
# ls $1 > $2/nodes.txt
# cd $2
# while read node_line
# do
# 	mkdir "$node_line"
# done < nodes.txt 
# rm nodes.txt

# TOTAL_COUNT=0
# COMPLETED_COUNT=0

# cd ../$1 
# ls > nodes.txt
# while read node_line
# do
# 	ls $node_line > guards.txt
# 	while read guard_line
# 	do
# 		FINISH_STATUS=`cat $node_line/"$guard_line" | tail -1 | grep -q "\* \* \*" && echo $?`
# 		if [ "$FINISH_STATUS" != "0" ]; 
# 		then
# 			cat $node_line/"$guard_line" | grep -o '\[AS[0-9]*\]' | awk '!x[$0]++' > ../$2/$node_line/"$guard_line" &
# 			((COMPLETED_COUNT++))
# 		fi
# 		((TOTAL_COUNT++))
# 	done < guards.txt 
# 	rm guards.txt 
# done < nodes.txt 
# rm nodes.txt 

# echo "Completed Traceroutes: $COMPLETED_COUNT"
# echo "Total Traceroutes: $TOTAL_COUNT"
