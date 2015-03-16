#!/bin/bash
#--------------------------------------------------------------
# Purpose: Inserts traceroute files into database
# Execution: bash insertIntoDb.sh <traceroutes folder name> 
# Author: Oscar Li
#--------------------------------------------------------------

CURR_DIR=`pwd`
DATA_FOLDER=$1

cd $DATA_FOLDER

# For some reason, we get these weird files that mess up the script. 
# This command deletes those files
find $DATA_FOLDER -name "(*)" -exec rm '{}' \;

if [[ $1 == *entryExit* ]];
then
	type="Both"
elif [[ $1 == *exit* ]]
then
	type="Exit"
else
	type="Entry"
fi

# For logging progress
base=`basename "$DATA_FOLDER"`
touch "$CURR_DIR"/logs/$base

for host in *
do
	psql -U oli -d raptor -w -c "\copy paths from '$CURR_DIR/$DATA_FOLDER/$host' (DELIMITER '~')"
	rm $host 
done

cd ..

rmdir $DATA_FOLDER