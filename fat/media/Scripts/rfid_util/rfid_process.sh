#!/bin/bash

##coded-with-claws
unset gamefound
while read -r line; do
	rfid=$(echo "$line" | cut -f1)
	game=$(echo "$line" | cut -f2)
	if [[ "$rfid" = "$1" ]]; then
		gamefound="$game"
		break
	fi
done </media/fat/Scripts/rfid_util/game_list.conf

if [ "x$gamefound" == "x" ]; then
	echo "RFID tag not found in config file..."
	return
fi

echo "Running: $gamefound"
mpg123 -q /media/fat/Scripts/rfid_util/rfid_process.mp3
sam="/media/fat/Scripts/MiSTer_SAM_on.sh"
if [[ "$(ps -o pid,args | grep '[M]iSTer_SAM_on.sh')" ]]; then
	"${sam}" playcurrent
fi
eval "$gamefound"
##
