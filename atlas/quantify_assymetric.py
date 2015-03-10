# --------------------------------------------------------
# Purpose: Calculates percentage of Tor circuits are vulnerable
# 			to AS level attacks (this time with assymetric analysis)
# Execution: python quantify.py <set 1> <set 2> <set 3> <set 4>
#
# Notes: Meant for use with atlas results
# --------------------------------------------------------

import glob
import sys
import os

compromisedCircuits = set()
circuits = set()

# Given a file, returns an array in which each element
# contains a line of the file
def fileToArray(f):
	data = [x.strip('\n') for x in f.readlines()]
	
	return data

# Given a file with a list of ASes, constructs a 
# set of ASes
def makeSet(file):
	s = set()

	for AS in file:
		s.add(AS)

	return s 

# So reverse paths and forward paths are considered to be part
# of the same circuit 
def format(name, reverse):
	srcDest = os.path.basename(name)
	arr = srcDest.split("-")

	# Incredibly bad style but handles some matching errors
	if arr[0] == "8966":
		arr[0] = "5384"
	if arr[1] == "8966":
		arr[1] = "5384"

	if arr[0] == "59249":
		arr[0] = "3"
	if arr[1] == "59249":
		arr[1] = "3"

	if arr[0] =="60781":
		arr[0] = "16265"
	if arr[1] =="60781":
		arr[1] = "16265"

	if arr[0] =="131148":
		arr[0] = "3462"
	if arr[1] =="131148":
		arr[1] = "3462"

	if reverse:
		temp = arr[1]
		arr[1] = arr[0]
		arr[0] = temp

	return arr[0] + "-" + arr[1]


def analyze(d1, d2, format1, format2):
	global compromisedCircuits
	global circuits

	for aspath1 in d1: 
		f1 = open(aspath1, 'r')
		s1 = makeSet(f1)
		f1.close()

		for aspath2 in d2:
			f2 = open(aspath2, 'r')
			s2 = makeSet(f2)
			f2.close()

			srcDest1 = format(aspath1, format1)
			srcDest2 = format(aspath2, format2)

			circuit_id = srcDest1 + "_" + srcDest2
			
			circuits.add(circuit_id)
			
			# If the two sets of ASes are not disjoint (i.e. they 
			# have a common AS), the circuit can be compromised.
			if not s1.isdisjoint(s2):
				compromisedCircuits.add(circuit_id)

# Contains the file paths to each day's set 
arr1 = fileToArray(open(sys.argv[1]))
arr2 = fileToArray(open(sys.argv[2]))
arr3 = fileToArray(open(sys.argv[3]))
arr4 = fileToArray(open(sys.argv[4]))

# length should be the same for both arrays
length = len(arr1)

for i in range(0, length):
	dataset1 = glob.glob(arr1[i] + "/*")
	dataset2 = glob.glob(arr2[i] + "/*")
	dataset3 = glob.glob(arr3[i] + "/*")
	dataset4 = glob.glob(arr4[i] + "/*")

	# Can comment out the last three lines if you want to do non-assymetric 
	# analysis
	analyze(dataset1, dataset2, False, False)

	percent = 1.0 * len(compromisedCircuits) / len(circuits)
	print "Day " + str(i + 1) + ": " + str(len(compromisedCircuits)) + " / " + str(len(circuits)) + " = " + str(percent)
	print
