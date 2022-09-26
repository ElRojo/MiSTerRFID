#!/bin/bash

write_rom() {

  cardNumber="$1"
  coreName=$(cat /tmp/CORENAME)
  startPath=$(cat /tmp/STARTPATH)
  fullPath=$(cat /tmp/FULLPATH)
  currentPath=$(cat /tmp/CURRENTPATH)
  runningGame=${fullPath}/${currentPath}
  rbfFile=$(cat /tmp/STARTPATH | awk -F '_' '{print $2}')
  gamePath=/media/fat/"$runningGame"
  thePath=${gamePath}/${currentPath}

  case $coreName in
  "PSX") extension=".cue" ;;
  "SNES") extension=".snes" ;;
  "NES") extension=".nes" ;;
  *) extension=".mra" ;;
  esac

  writeMgl() {
    sedPath="$thePath""$extension".mgl
    if [ ! -f "$sedPath" ]; then
      echo "<mistergamedescription><rbf>_"$rbfFile"</rbf><file delay=\"2\" type=\"f\" index=\"0\" path=\"../../"$runningGame"/"$currentPath""$extension"\"/></mistergamedescription>" >"$sedPath"
    fi
  }

  writeArcade() {
    arcadeWithGame=$(cat /tmp/STARTPATH | awk -F /media/fat/ '{printf $2}' | awk -F .mra '{printf $1}')
    sedPath=/media/fat/"$arcadeWithGame""$extension"
  }
  case $extension in
  ".mra") writeArcade ;;
  *) writeMgl ;;
  esac

  rfidFile=/media/fat/Scripts/rfid_process.sh
  sed -i "/$cardNumber/d" "$rfidFile"
  # '14i...' is the starting line for the case-statement. Change this if you add code or newlines to rfid_process.sh
  sed -i "14i \"$cardNumber\") play \"$sedPath\" ;;" "$rfidFile"
}

write_rom "$1"
