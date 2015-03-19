# --------------------------------------------------------
# Purpose: Deletes all specified UDMs
# Execution: bash deleteMeasurement.sh <measurement numbers>
# Author: Oscar Li
# --------------------------------------------------------

while read num
do 
	curl --dump-header - -X DELETE https://atlas.ripe.net/api/v1/measurement/$num/?key=e933151e-7e62-4705-bae4-c0caeadf7fbd
done < $1