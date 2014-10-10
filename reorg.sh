#--------------------------------------------------------------
# Purpose: (Deprecated) Reorganizes files copied from PL nodes
# Execution: bash reorg.sh <DIRNAME>
# Author: Oscar Li
#--------------------------------------------------------------
DIRNAME=$1

# Reorganizes files
cd "$DIRNAME"
ls > nodes.txt 
while read node_line
do
  cd $node_line
  ls > guards.txt 
  while read guard_line
  do 
    guard=`echo $guard_line | cut -f1 -d"("`

    # Creates folder for node if it does not already exist
    if [ ! -e ../../results/$node_line ];
    then
      cd ~/results
      mkdir $node_line
      cd ~/"$DIRNAME"/$node_line
    fi

    # Creates folder for guard if it does not already exist
    if [ ! -e ../../results/$node_line/$guard ];
    then
      cd ~/results/$node_line
      mkdir $guard
      cd ~/"$DIRNAME"/$node_line
    fi

    cp "$guard_line" ~/results/$node_line/$guard
  done < guards.txt
  rm guards.txt 
  cd ..
done < nodes.txt 
rm nodes.txt
cd 
rm -r "$DIRNAME"