#!/bin/bash

write_rom() {

  cardNumber="$1"
  coreName=$(cat /tmp/CORENAME)
  startPath=$(cat /tmp/STARTPATH)
  fullPath=$(cat /tmp/FULLPATH)
  game=$(cat /tmp/CURRENTPATH)
  rootPath=/media/fat/
  fullGameDir="$rootPath""$fullPath"/"$game"              #/media/fat/games/CORE/Gamedir
  rbfFile=_$(cat /tmp/STARTPATH | awk -F _ '{printf $2}') #_Folder/CORE

  writeMgl() {
    if [ ! -f "$SedPath" ]; then
      echo "<mistergamedescription><rbf>"$rbfFile"</rbf><file delay=\"2\" type=\"f\" index=\"0\" path=\"../../"$relativeGameDir"\"/></mistergamedescription>" >"$sedPath"
    fi
  }

  writeArcade() {
    arcadeWithGame=$(cat /tmp/STARTPATH | awk -F /media/fat/ '{printf $2}' | awk -F .mra '{printf $1}')
  }

  if [[ ${startPath} = *".mgl" ]]; then
    return
  fi

  if [[ ${fullPath} != "_Arcade" ]]; then
    fileFinder=$(ls -1 "$fullGameDir"/)
    case $fileFinder in
    *".cue") extension=".cue" ;;
    *".chd") extension=".chd" ;;
    *".sfc") extension=".sfc" ;;
    *".smc") extension=".smc" ;;
    *".gen") extension=".gen" ;;
    *".nes") extension=".nes" ;;
    *".md") extension=".md" ;;
    esac
    relativeGameDir="$fullPath"/"$game"/"$game""$extension" #games/CORE/Gamedir/Game.EXTENSION
    sedPath="$fullGameDir"/"$game""$extension".mgl          #/media/fat/games/CORE/Gamedir/Game.EXTENSION.mgl
  elif [[ ${fullPath} = "_Arcade" ]]; then
    extension=".mra"
    sedPath="$rootPath""$arcadeWithGame""$extension"
  fi

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
