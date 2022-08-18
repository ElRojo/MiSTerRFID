#!/bin/bash

play() {
        coreCommand="load_core /media/fat/_Arcade/"$1".mra"
        echo "$coreCommand" > /dev/MiSTer_cmd
}

ha_cmd() {
        TOKEN=""
        curl -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d $1 $2 
}

case "$1" in 

esac
