# --------------------------------------------------------
# Purpose: Extracts and prints source and destination IPs
#		   from RIPE Atlas traceroute JSON data
# Execution: python extractSrcDestIP.py <json file>
# --------------------------------------------------------

import json 
import sys 


# Loads in JSON data
jsonData = open(sys.argv[1])
sectionData = json.load(jsonData)

print "begin"
print sectionData[0]['from']
print sectionData[0]['dst_addr']
print "end"
