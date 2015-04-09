# --------------------------------------------------------
# Purpose: Prints each AS with its % Tor relay BW
# Execution: python torConcentration.py <Type of Relay>
# Notes: Make sure Tor control port is running, need ipwhois
# --------------------------------------------------------

from ipwhois import IPWhois
from stem.control import Controller
import StringIO
import re
import sys

totBW = 0
AS_BW = dict() 

RELAY_TYPE = sys.argv[1] # Guard, Exit, Running

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
			AS = IPWhois(ip).lookup()['asn']

			if AS in AS_BW:
				AS_BW[AS] += bandwidth
			else:
				AS_BW[AS] = bandwidth

			totBW += bandwidth

for key, value in AS_BW.iteritems():
	percent = 1.0 * value / totBW
	print str(percent) + " AS: " + key 