#!/bin/bash
#--------------------------------------------------------------
# Purpose: For every srcas-destas pair, calculates how often AS 
#		   paths change
# Execution: bash asPathStats.sh 
# Author: Oscar Li
#--------------------------------------------------------------

mkdir aspathcounts
while read pair
do
	srcas=`echo $pair | cut -d'~' -f1` 
	destas=`echo $pair | cut -d'~' -f2`
	query="\copy (SELECT COUNT(aspath) FROM paths WHERE srcas='$srcas' AND destAS='$destas' AND valid = true) TO '~/aspathcounts/$srcas-$destas'"
	psql -U oli -d raptor -w -c "$query" &
	sleep 5
done < asPairs.txt
