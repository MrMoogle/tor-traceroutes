# --------------------------------------------------------
# Purpose: Prints 5 Tor guards with highest bandiwidths 
# Execution: python tor_getHighestBWEntryNodes.py
# Notes: Make sure Tor control port is running
# --------------------------------------------------------

from stem.control import Controller
import StringIO
import re
import sys

# Stores (ip, bandwidth) pairs with highest bandwidths
l = [("", 0),("", 0),("", 0),("", 0), ("", 0)]

# Length of L
LENGTH = 5

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
		if "Bandwidth" in line and "Guard" in prevLine:
			bandwidth = re.search(r'\d+', line)
			ip = re.search('\d+\.\d+\.\d+\.\d+', prevPrevLine)
			insert((ip.group(), int(bandwidth.group())))

		prevPrevLine = prevLine 
		prevLine = line

# For debug
# print l

for i in range(LENGTH):
	print l[i][0]
