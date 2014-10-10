mkdir "$1"

while true         
do 
	DATE=`date +%m-%d-%y-%k:%M`    
	traceroute -A $1 > "$1"/"$DATE" & 
	sleep 5m
done