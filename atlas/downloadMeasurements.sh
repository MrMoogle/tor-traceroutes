# --------------------------------------------------------
# Purpose: Downloads all atlas traceroute measurements and
#			extracts AS level paths
# Execution: bash downloadMeasurements.sh <input folder> <output folder>
# --------------------------------------------------------

# Command line arguments
inputFolder=$1
outputFolder=$2

# Downloads traceroute and extracts AS level path
function download
{
	n=$1
	fp=$2

	# Gets raw traceroute JSON data
	curl -s https://atlas.ripe.net/api/v1/measurement/$n/result/?format=json > $fp/$n.json
	
	# In case the measurement failed
	contents=`cat $fp/$n.json`
	if [ "$contents" = "[]" ]; 
	then 
		rm $fp/$n.json 
		return 
	fi 

	# Extracts source and destination AS from traceroute JSON
	python ~/Desktop/"Independent Work"/tor-traceroutes/atlas/extractSrcDestIP.py $fp/$n.json > $fp/destsrc$n
	netcat whois.cymru.com 43 < $fp/destsrc$n | awk '{print $1}' | tail -n +2 > $fp/temp_destsrc$n

	srcAS=`head -1 $fp/temp_destsrc$n`
	destAS=`tail -1 $fp/temp_destsrc$n`
	
	rm $fp/destsrc$n
	rm $fp/temp_destsrc$n

	grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+" $fp/$n.json > $fp/"$srcAS-$destAS"
	echo "begin" | cat - $fp/"$srcAS-$destAS" > $fp/"temp$srcAS-$destAS" 
	mv $fp/"temp$srcAS-$destAS" $fp/"$srcAS-$destAS" 
	echo "end" >> $fp/"$srcAS-$destAS" 
	rm $fp/$n.json

	netcat whois.cymru.com 43 < $fp/"$srcAS-$destAS" | awk '{print $1}' | awk '!x[$0]++' | tail -n +2 | grep -o "[0-9]\+" > $fp/"temp$srcAS-$destAS" 
	mv $fp/"temp$srcAS-$destAS" $fp/"$srcAS-$destAS"
}

# Folder with AS level paths
mkdir $outputFolder

cd $inputFolder
for day in *
do	
	mkdir ../$outputFolder/"$day"
	cd "$day"

	# d1, d2, d3, d4
	for set in *
	do
		dest="../../$outputFolder/$day/$set"
		mkdir $dest

		while read line
		do 
			mNum=`echo $line | cut -f2 -d "[" | cut -f1 -d "]" | grep -o "^[0-9]\+"`
			
			if [ ! -z "$mNum" ];
			then 
				download $mNum $dest & 
				sleep 0.25
			fi
		done < $set
	done 

	cd .. 
done 