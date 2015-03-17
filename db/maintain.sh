#!/bin/bash
#--------------------------------------------------------------
# Purpose: Performs database maintenance: fills in missing
#		   values, deletes invalid entries, etc.
# Execution: bash maintain.sh 
# Author: Oscar Li
#--------------------------------------------------------------

CURR_DIR=`pwd`

# Deletes invalid entries 
psql -U oli -d raptor -w -c "DELETE FROM paths WHERE path LIKE '%bind_public%'"
psql -U oli -d raptor -w -c "DELETE FROM paths WHERE srcip='' OR path='' OR aspath='' OR numases=0"

# Sometimes, srcas is not mapped so we do it here
psql -U oli -d raptor -w -c "\copy (SELECT DISTINCT srcip, srcas FROM paths WHERE srcas='') TO '$CURR_DIR/temp.csv'"
echo "begin" > ip.csv
cat temp.csv >> ip.csv
echo "end" >> ip.csv

nc whois.cymru.com 43 < ip.csv | tail -n +2 | awk '{print $1 " " $3}' > list.txt

while read pair          
do
	AS=`echo $pair | awk '{print $1}'`
	IP=`echo $pair | awk '{print $2}'`

	psql -U oli -d raptor -w -c "UPDATE paths SET srcas='$AS' WHERE srcas='' AND srcip='$IP'"
done < list.txt 