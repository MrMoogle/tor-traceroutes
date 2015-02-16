#!/bin/bash
#--------------------------------------------------------------
# Purpose: For every srcas-destas pair, calculates how often AS 
#		   paths change
# Execution: bash asPathStats.sh 
# Author: Oscar Li
#--------------------------------------------------------------

# Gets all source AS - destination AS pairs
query="\copy (SELECT destas, srcas FROM paths WHERE valid=true GROUP BY destas, srcas) TO ~/temp.txt (DELIMITER '~');"
psql -U oli -d raptor -w -c "$query"
grep "AS[0-9]\+~AS[0-9]\+" temp.txt > asPairs.txt # filters out potential bad data
rm temp.txt

mkdir aspath
while read pair
do
	srcas=`echo $pair | cut -d'~' -f1` 
	destas=`echo $pair | cut -d'~' -f2`
	query="\copy (SELECT COUNT(DISTINCT aspath) FROM paths WHERE srcas='$srcas' AND destAS='$destas' AND valid = true) TO '~/aspath/$srcas-$destas'"
	psql -U oli -d raptor -w -c "$query"
done < asPairs.txt

