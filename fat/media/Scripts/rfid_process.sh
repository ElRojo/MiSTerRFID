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
eval "$gamefound"
##
