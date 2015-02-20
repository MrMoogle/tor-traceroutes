# --------------------------------------------------------
# Purpose: Updates file with new Tor entry guards
# Execution: python tor_getEntryRelays.py Entryguards.txt
# Notes: Make sure Tor control port is running
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
		if "Guard" in line:
			match = re.search(r'\d+\.\d+\.\d+\.\d+', prevLine)
			if match:
				f.write(match.group() + "\n")

		prevLine = line

# Closes file 
f.close()

# Opens file to read
f = open(sys.argv[1], "r+")

# Reads and sorts all lines
lines = [line for line in f if line.strip()]
f.close()
lines.sort()

# Removes duplicates and prints
prevLine = ""
for l in lines:
	if l != prevLine:
		sys.stdout.write(l)
	prevLine = l