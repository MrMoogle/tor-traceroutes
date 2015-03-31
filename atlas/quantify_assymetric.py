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

client = ('12880', '174', '20773', '2497', '41495', '4766', '5384', '6128',
		  '6893', '7992')

guard = ('1101', '12876','13213','15626','16265','16276','1653','1764','197019',
		'24940','24961','2603','28717','29695','3','35366','37560','39743',
		'49367','51290','51395','680','6939','8437','8560')

exit = ('1101', '12876','13030','13213','16276','1653','197019','197422','24940',
		'24961','250','28717','29405','3','35366','37560','39743','43289',
		'49544','50618','51290','51395','51815','6939','8560')

dest = ('14907', '16265', '23393', '26134', '3356', '3462', '36351',
		'4134', '4713', '4812')

compromisedCircuits = set()
circuits = set()
as_circuitIDPairs = dict() 

# Given a set of ASes and a circuit ID, adds AS - Circuit ID pairs
# to as_circuitIDPairs 
# def addToAS_circuitIDPairs(asSet, circuitID):
# 	global as_circuitIDPairs

# 	for AS in asSet:
# 		if AS in as_circuitIDPairs:
# 			as_circuitIDPairs[AS].add(circuitID)
# 		else:
# 			as_circuitIDPairs[AS] = set() 


# Given a file, returns an array in which each element
# contains a line of the file
def fileToArray(f):
	data = [x.strip('\n') for x in f.readlines()]
	
	return data

# Given a file with a list of ASes, constructs a 
# set of ASes
def makeSet(file, ): 
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
	global client, guard, exit, dest 

	for aspath1 in d1:
		srcDest1 = format(aspath1, format1)

		f1 = open(aspath1, 'r')
		s1 = makeSet(f1)
		f1.close()

		for aspath2 in d2:
			srcDest2 = format(aspath2, format2)

			f2 = open(aspath2, 'r')
			s2 = makeSet(f2)
			f2.close()

			circuit_id = srcDest1 + "_" + srcDest2

			# addToAS_circuitIDPairs(s1, circuit_id)
			# addToAS_circuitIDPairs(s2, circuit_id)

			entry_segment = srcDest1.split("-")
			exit_segment = srcDest2.split("-")
			clientAS = entry_segment[0]
			guardAS = entry_segment[1]
			exitAS = exit_segment[0]
			destAS = exit_segment[1]

			if (clientAS in client) and (guardAS in guard) and (exitAS in exit) and (destAS in dest):
				circuits.add(circuit_id)
				
				# If the two sets of ASes are not disjoint (i.e. they 
				# have a common AS), the circuit can be compromised.
				if not s1.isdisjoint(s2):
					compromisedCircuits.add(circuit_id)

				# intersection = s1 & s2 

				# for AS in intersection: 
				# 	fAS = AS.rstrip()

				# 	if (fAS not in client) and (fAS not in guard) and (fAS not in exit) and (fAS not in dest):
				# 		compromisedCircuits.add(circuit_id)
				# 		break


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
	analyze(dataset4, dataset3, True, True)
	analyze(dataset4, dataset2, True, False)
	analyze(dataset1, dataset3, False, True)

	percent = 1.0 * len(compromisedCircuits) / len(circuits)
	print "Day " + str(i + 1) + ": " + str(len(compromisedCircuits)) + " / " + str(len(circuits)) + " = " + str(percent)
	print

# for key, value in as_circuitIDPairs.iteritems():
# 	percent = 1.0 * len(value) / len(circuits)
# 	print str(percent) + " AS: " + key
