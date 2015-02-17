#--------------------------------------------------------------
# Purpose: Gets all valid source AS - destination AS pairs
# Execution: bash getSrcDestASPairs.sh
# Author: Oscar Li
#--------------------------------------------------------------

query="\copy (SELECT DISTINCT srcas, destas FROM paths WHERE valid=true) TO ~/temp.txt (DELIMITER '~');"
psql -U oli -d raptor -w -c "$query"
grep "AS[0-9]\+~AS[0-9]\+" temp.txt > asPairs.txt # filters out potential bad data
rm temp.txt
