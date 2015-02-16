#!/bin/bash
#--------------------------------------------------------------
# Purpose: For every srcas-destas pair, calculates how often AS 
#		   paths change
# Execution: bash asPathStats.sh 
# Author: Oscar Li
#--------------------------------------------------------------

# Gets all source ASes
query="\copy (SELECT DISTINCT srcas FROM paths) TO ~/temp.txt"
psql -U oli -d raptor -w -c "$query"
grep -o "AS[0-9]\+" temp.txt > srcASes.txt # filters out potential bad data
rm temp.txt

# Gets all destination ASes
query="\copy (SELECT DISTINCT destas FROM paths) TO ~/temp.txt"
psql -U oli -d raptor -w -c "$query"
grep -o "AS[0-9]\+" temp.txt > destASes.txt # filters out potential bad data
rm temp.txt

mkdir aspath
while read srcas
do
	while read destas
	do 
		query="\copy (SELECT COUNT(DISTINCT aspath) FROM paths WHERE srcas='$srcas' AND destAS='$destas' AND valid = true) TO '~/aspath/$srcas-$destas'"
		psql -U oli -d raptor -w -c "$query" &
		sleep 1 # to avoid using up all the database
	done < destASes.txt
done < destASes.txt

