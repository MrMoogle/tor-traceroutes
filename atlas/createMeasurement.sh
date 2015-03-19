# --------------------------------------------------------
# Purpose: Creates RIPE UDMs given a set of ASes (source)
#		   and destination IP's 
# Execution: bash createMeasurement.sh <origin ASes> <destination IPs> <description>
# Author: Oscar Li
# --------------------------------------------------------

# Format: 
# 
# curl -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d '
# { 
# 	"definitions": 
# 	[{ 
# 		"target": <ip address>, 
# 		"description": <description>,  
# 		"type": "traceroute", 
# 		"af": 4,
# 		"protocol": "ICMP",
# 		"interval": 86400 OR "is_oneoff": "true"
# 	}], 
# 	"probes": 
# 	[{ 
# 		"requested": 1, 
# 		"type": "asn", 
# 		"value": <AS Number>
# 	}]
# }' https://atlas.ripe.net/api/v1/measurement/?key=1a4a1754-4b02-4016-a8c9-a21d4b1d1c60

DATE=`date +%m-%d-%y`

while read AS
do
	while read IP
	do 
		data="$( printf '{
			"definitions": 
			[{ 
				"target": "%s", 
				"description": "%s", 
				"type": "traceroute", 
				"af": 4,
				"protocol": "ICMP",
				"is_oneoff": "true" 
			}], 
			"probes": 
			[{ 
				"requested": 1, 
				"type": "asn", 
				"value": "%s" 
			}]
		}' "$IP" "$3" "$AS" )"
	
		curl -H 'Content-Type: application/json' -H "Accept: application/json" -X POST -d "$data" https://atlas.ripe.net/api/v1/measurement/?key=1a4a1754-4b02-4016-a8c9-a21d4b1d1c60
		echo 

		# To get around Atlas constraints
		sleep 10
	done < $2
done < $1



