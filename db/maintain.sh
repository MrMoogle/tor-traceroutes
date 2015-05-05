#!/bin/bash
#--------------------------------------------------------------
# Purpose: Performs database maintenance: fills in missing
#		   values, deletes invalid entries, etc.
# Execution: bash maintain.sh 
# Author: Oscar Li
#--------------------------------------------------------------

CURR_DIR=`pwd`

###############################################################################
# Syncs files to PlanetLab Machines 
###############################################################################
while read PL 
do 
	scp -o BatchMode=yes -o ConnectTimeout=5 ~/tor-traceroutes/pl/hostSelfIdentify.sh princeton_oscar@$PL:.
	scp -o BatchMode=yes -o ConnectTimeout=5 ~/tor-traceroutes/pl/trace.sh princeton_oscar@$PL:. 

	ssh -n -o BatchMode=yes -o ConnectTimeout=5 princeton_oscar@$1 "nohup bash hostSelfIdentify.sh &"
done < ~/backup/allNodes.txt & 

###############################################################################
# Deletes invalid entries 
###############################################################################
psql -U oli -d raptor -w -c "DELETE FROM paths WHERE path LIKE '%bind_public%'"
psql -U oli -d raptor -w -c "DELETE FROM paths WHERE srcip='' OR path='' OR aspath='' OR numases=0 OR destip=''"
psql -U oli -d raptor -w -c "DELETE FROM paths WHERE srcip='*' or destip='*'" 

###############################################################################
# Fixes invalid entries 
###############################################################################
# Sometimes, srcas is not mapped so we do it here 
psql -U oli -d raptor -w -c "\copy (SELECT DISTINCT srcip, srcas FROM paths WHERE srcas NOT LIKE 'AS%' or srcas='AS') TO '$CURR_DIR/temp.csv'"
echo "begin" > src_ip.csv
cat temp.csv >> src_ip.csv
echo "end" >> src_ip.csv

nc whois.cymru.com 43 < src_ip.csv | tail -n +2 | awk '{print $1 " " $3}' > list.txt

while read pair          
do
	AS=AS`echo $pair | awk '{print $1}'`
	IP=`echo $pair | awk '{print $2}'`

	query="UPDATE paths SET srcas='$AS' WHERE (srcas NOT LIKE 'AS%' or srcas='AS') AND srcip='$IP'"
	psql -U oli -d raptor -w -c "$query"
done < list.txt 

# Sometimes, destas is not mapped so we do it here
query="\copy (SELECT DISTINCT destip, destas FROM paths WHERE destas NOT LIKE 'AS%' OR destas='AS') TO '$CURR_DIR/temp.csv'"
psql -U oli -d raptor -w -c "$query"
echo "begin" > dest_ip.csv
cat temp.csv >> dest_ip.csv
echo "end" >> dest_ip.csv

nc whois.cymru.com 43 < dest_ip.csv | tail -n +2 | awk '{print $1 " " $3}' > list.txt

while read pair          
do
	AS=AS`echo $pair | awk '{print $1}'`
	IP=`echo $pair | awk '{print $2}'`

	query="UPDATE paths SET destas='$AS' WHERE (destas NOT LIKE 'AS%' or destas='AS') AND destip='$IP'"
	echo $query

	psql -U oli -d raptor -w -c "$query"
done < list.txt 


# Deletes stuff
rm src_ip.csv
rm dest_ip.csv 
rm list.txt
rm temp.csv 