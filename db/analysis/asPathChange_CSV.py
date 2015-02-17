# --------------------------------------------------------
# Purpose: Calculates and prints how much an AS level path
#		   (i.e how many new ASes not on the baseline path
#			 appears on the path)
# Execution: python asPathChange.py <CSV file>
# Notes: Meant for use with asPathChange.sh
# --------------------------------------------------------

import csv
import sys

basePath = True
basePathASes = set()
additionalASes = set()

with open(sys.argv[1], 'rb') as csvfile:
	reader = csv.reader(csvfile, delimiter='~')
	for row in reader:
		for AS in row:
			if basePath:
				basePathASes.add(AS)
			else:
				if AS not in basePathASes:
					additionalASes.add(AS)


		basePath = False

print len(additionalASes)
