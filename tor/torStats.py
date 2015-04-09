# --------------------------------------------------------
# Purpose: Prints total Tor entry/exit relay bandwidth and
#		   number of Tor entry/exit relays  
# Execution: python torStats.py 
# Notes: Tor control port must be running
# Author: Oscar Li
# --------------------------------------------------------
from stem.control import Controller
import StringIO
import re

# Interfaces with the Tor control port
entryBW = 0
exitBW = 0
allBW = 0 
numEntryNodes = 0
numExitNodes = 0 
numAllNodes = 0

with Controller.from_port(port = 9051) as controller:
	controller.authenticate("") 

	relays = controller.get_info("ns/all")
	buf = StringIO.StringIO(relays)

	prevPrevLine = ""
	prevLine = ""
	for line in buf:
		if "Bandwidth" in line and "Exit" in prevLine:
			bandwidth = re.search(r'\d+', line)
			exitBW+= int(bandwidth.group()) 
			numExitNodes+= 1
		if "Bandwidth" in line and "Guard" in prevLine: 
			bandwidth = re.search(r'\d+', line)
			entryBW+= int(bandwidth.group())
			numEntryNodes+= 1
		if "Bandwidth" in line and "Running" in prevLine: 
			bandwidth = re.search(r'\d+', line)
			allBW+= int(bandwidth.group())
			numAllNodes+= 1

		prevPrevLine = prevLine 
		prevLine = line

	print str(numExitNodes) + " Exit nodes with " + str(exitBW) 
	print str(numEntryNodes) + " Guard nodes with " + str(entryBW)
	print str(numAllNodes) + " Running nodes with " + str(allBW)