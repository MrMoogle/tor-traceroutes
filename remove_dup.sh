#!/bin/bash
# removes duplicates from given sorted text file

PREVLINE=hi
sort $1 > temp.txt
while read line
do
	if [ "$PREVLINE" != "$line" ]; then
		echo $line
	fi

	PREVLINE=$line
done < temp.txt
rm temp.txt
