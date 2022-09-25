#!/bin/bash

write_rom()
{
    cardNumber="$1"
    runningGame=\"$(ps aux | awk -F '/media/fat/' '{printf $4}')\"

  rfidFile=/media/fat/Scripts/rfid_process.sh
  sed -i "/$cardNumber/d" "$rfidFile"
  # '14i...' is the starting line for the case-statement. Change this if you add code or newlines to rfid_process.sh
  sed -i "14i \"$cardNumber\") "play" \"$gameTitle\" ;;" "$rfidFile"
  
}

write_rom "$1"