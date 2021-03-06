# --------------------------------------------------------
# Purpose: Appends all Tor entry relays to a file
# Execution: python tor_getEntryRelays.py Entryguards.txt
# Notes: Make sure Tor control port is running
# Use awk to remove duplicates
# --------------------------------------------------------

from stem.control import Controller
import StringIO
import re
import sys

# Opens file to append text output
f = open(sys.argv[1], "a")

# Interfaces with the Tor control port
with Controller.from_port(port = 9051) as controller:
	controller.authenticate("") 

	relays = controller.get_info("ns/all")
	buf = StringIO.StringIO(relays)

	prevLine = ""
	for line in buf:
		if "Guard" in line and "Exit" not in line:
			match = re.search(r'\d+\.\d+\.\d+\.\d+', prevLine)
			if match:
				f.write(match.group() + "\n")

		prevLine = line

# Closes file 
f.close()