# --------------------------------------------------------
# Purpose: Retrieves and prints all active PL nodes from 
#          PLE and PLC to stdout
# Execution: python retrieveActiveNoes.py
# Deprecated: http://monitor.planet-lab.org/monitor/query
# 				is down
# --------------------------------------------------------

import urllib
import urllib2

# We want all the nodes from PLE and PLC
url1 = 'http://monitor.planet-lab.org/monitor/query'
url2 = 'http://monitor.planet-lab.eu/monitor/query'

values = {'hostname' : 'on',
          'tg_format' : 'plain',
          'object' : 'nodes',
          'observed_status': 'on' }

data = urllib.urlencode(values)

# PLC
req1 = urllib2.Request(url1, data)
response1 = urllib2.urlopen(req1)
plc_page = response1.read()

# PLE
req2 = urllib2.Request(url2, data)
response2 = urllib2.urlopen(req2)
ple_page = response2.read()

# Combines PLE and PLC
nodes =  plc_page + ple_page
lines = nodes.splitlines()

# Prints all nodes in BOOT state
for i in range(0, len(lines)):
	temp = lines[i].split(",")
	if temp[1] == "BOOT":
		print temp[0]