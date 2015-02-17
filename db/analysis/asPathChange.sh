#!/bin/bash
#--------------------------------------------------------------
# Purpose: For every srcas-destas pair, calculates how many 
# 			additional ASes appear on the path 
# Execution: bash asPathChange.sh > <output file>
# Author: Oscar Li
#--------------------------------------------------------------

mkdir asPathChange
while read pair
do
	srcas=`echo $pair | cut -d'~' -f1` 
	destas=`echo $pair | cut -d'~' -f2`
	path="~/asPathChange/$srcas-$destas"

	query="\copy (SELECT aspath FROM paths WHERE srcas='$srcas' AND destAS='$destas' AND valid = true) TO '$path'"	
	psql -U oli -d raptor -w -c "$query"

	awk '{amount [$1]+=1} END 
	 	 {for (name in amount) print name, amount[name] | "sort -k2 -nr"}' $path | sed 's/\\n/~/g' | cut -d' ' -f1 > $path.data
	rm $path 
	numASes=`python tor-traceroutes/db/analysis/asPathChange_CSV.py $path.data`

	echo "$srcas $destas $numASes"
done < asPairs.txt
