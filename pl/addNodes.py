import xmlrpclib
api_server = xmlrpclib.ServerProxy('https://www.planet-lab.org/PLCAPI/')
array = [""]

# login credentials
auth = {}
auth['AuthMethod'] = "password"
auth['Username'] = "" # email address
auth['AuthString'] = "" # password

#Checks if we are authorized
authorized = api_server.AuthCheck(auth)
if authorized:
	print 'We are authorized!'
else:
	print 'Authentication Error'

# Adds all nodes to the slice
all_nodes = api_server.GetNodes(auth)
for entry in all_nodes:
	print entry['hostname']
	# array.append(entry['hostname'])

#your slicename in the middle argument (e.g. "princeton_oli")
# api_server.AddSliceToNodes(auth, "princeton_oscar", array) 
