#!/bin/bash

write_rom()
{
    cardNumber="$1"
    runningGame=\"$(ps aux | grep .mra)\"
    get_title() {   
    echo "$1" | awk -F 'media/fat/_Arcade/' '{print $3}' | awk -F '\\.mra' '{print $1}'
    }
    gameTitle=$(get_title "$runningGame")

  rfidFile=/media/fat/Scripts/rfid_process.sh
  sed -i "/$cardNumber/d" "$rfidFile"
  # '14i...' is the starting line for the case-statement. Change this if you add code or newlines to rfid_process.sh
  sed -i "14i \"$cardNumber\") "play" \"$gameTitle\" ;;" "$rfidFile"
  
}

write_rom "$1"

