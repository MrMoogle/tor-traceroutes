# --------------------------------------------------------
# Purpose: Prints n Tor entry/exit relays with highest bandwidths 
# Execution: 
#	1) python tor_getHighestBWEntryNodes.py n Exit
# 	2) python tor_getHighestBWEntryNodes.py n Guard
# Notes: 
# 	1) Tor control port must be running
#	2) Highest BW relays at bottom of list
# --------------------------------------------------------

from stem.control import Controller
import StringIO
import re
import sys

# Length of L
LENGTH = int(sys.argv[1])
RELAY_TYPE = sys.argv[2]

numNodes = 0

# Stores (ip, bandwidth) pairs with highest bandwidths
l = [] 
for i in range(0, LENGTH):
	l.append(("", 0))

# Inserts an (ip, bandwidth) pair into l if possible 
def insert((ip, bandwidth)):
	for i in range(LENGTH):
		if i == LENGTH - 1:
			l[i] = (ip, bandwidth)
			return 
		else:
			if bandwidth >= (l[i])[1]:
				if bandwidth <= (l[i + 1])[1]:
					l[i] = (ip, bandwidth)
					return 
				else:
					l[i] = l[i + 1]
			else:
				return 

# Interfaces with the Tor control port
with Controller.from_port(port = 9051) as controller:
	controller.authenticate("") 

	relays = controller.get_info("ns/all")
	buf = StringIO.StringIO(relays)

	prevPrevLine = ""
	prevLine = ""
	for line in buf:
		if "Bandwidth" in line and RELAY_TYPE in prevLine:
			bandwidth = re.search(r'\d+', line)
			ip = re.search('\d+\.\d+\.\d+\.\d+', prevPrevLine)
			insert((ip.group(), int(bandwidth.group())))
			numNodes+= 1

		prevPrevLine = prevLine 
		prevLine = line

# For debug
# print l
cumBW = 0 
for i in range(LENGTH):
	cumBW+= l[i][1]
	if (l[i][1] != 0):
		print l[i][0] + ": " + str(l[i][1])

print "Cumulative BW: " + str(cumBW)