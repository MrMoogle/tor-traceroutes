# --------------------------------------------------------
# Purpose: Extracts a list of measurement numbers from 
#		   the output of creating Atlas measurements via their API
# Execution: bash preprocess.sh <input folder> <output folder>
# --------------------------------------------------------

mkdir $2

# d1, d2, d3, d4
cd $1
for day in *
do 
	mkdir ../$2/$day
	cd $day 

	for set in *
	do
		touch ../../$2/$day/"$set" 

		while read line
		do 
			echo $line | cut -f2 -d "[" | cut -f1 -d "]" | grep -o "^[0-9]\+" >> ../../$2/"$day"/"$set"
		done < $set
	done 

	cd ..
done 