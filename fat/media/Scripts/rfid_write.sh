#!/bin/bash

write_rom() {

  #==========================================
  #             Env Variables              #
  #==========================================
  cardNumber="$1"
  mountType="f"
  indexVal="0"
  misterCmd=/dev/MiSTer_cmd
  confFile=/media/fat/Scripts/game_list_rfid.conf
  coreName=$(cat /tmp/CORENAME)
  startPath=$(cat /tmp/STARTPATH)
  fullPath=$(cat /tmp/FULLPATH)
  game=$(cat /tmp/CURRENTPATH)
  rootPath=/media/fat/
  fullGameDir="$rootPath""$fullPath"/"$game"              #/media/fat/games/CORE/Gamedir
  rbfFile=_$(cat /tmp/STARTPATH | awk -F _ '{printf $2}') #_Folder/CORE

  writeMgl() {
    if [ ! -f "$SedPath" ]; then
      echo "<mistergamedescription><rbf>"$rbfFile"</rbf><file delay=\"2\" type=\"$mountType\" index=\"$indexVal\" path=\"../../"$relativeGameDir"\"/></mistergamedescription>" >"$sedPath"
    fi
  }

  writeArcade() {
    arcadeWithGame=$(cat /tmp/STARTPATH | awk -F /media/fat/ '{printf $2}' | awk -F .mra '{printf $1}')
  }

  if [[ ${startPath} = *".mgl" ]]; then
    return
  fi

  if [[ ${fullPath} != *_Arcade* ]]; then
    if [[ ${coreName} = NEOGEO ]]; then
      extension=''
      rbfFile=_/Console/NEOGEO
    fi
    fileFinder=$(ls -1 "$fullGameDir"/)
    case $fileFinder in
    *".cue"*) extension=".cue" ;;
    *".chd"*) extension=".chd" ;;
    *".sfc"*) extension=".sfc" ;;
    *".smc"*) extension=".smc" ;;
    *".gen"*) extension=".gen" ;;
    *".nes"*) extension=".nes" ;;
    *".md"*) extension=".md" ;;
    esac

    case $coreName in
    "Amiga") mountType="f" indexVal=0 ;;
    "ATARI5200") mountType="f" indexVal=1 ;;
    "ATARI7800") mountType="f" indexVal=1 ;;
    "ATARI800") mountType="f" ;;
    "AtariLynx") mountType="f" indexVal=1 ;;
    "C64") mountType="f" indexVal=1 ;;
    "GAMEBOY" | "GAMEBOY2P") mountType="f" indexVal=0 ;;
    "GBA" | "GBA2P") mountType="f" indexVal=0 ;;
    "Genesis") mountType="f" indexVal=0 ;;
    "MegaCD") mountType="s" indexVal=0 ;;
    "NEOGEO") mountType="f" indexVal=1 ;;
    "NES") mountType="f" indexVal=0 ;;
    "S32X") mountType="f" indexVal=0 ;;
    "SMS") mountType="f" indexVal=1 ;;
    "SNES") mountType="f" indexVal=0 ;;
    "TGFX16") mountType="f" indexVal=0 ;;
    "TGFX16-CD") mountType="s" indexVal=0 ;;
    "PSX") mountType="s" indexVal=1 ;;
    *) mountType="f" indexVal=0 ;;
    esac

    relativeGameDir="$fullPath"/"$game"/"$game""$extension" #games/CORE/Gamedir/Game.EXTENSION
    sedPath="$fullGameDir"/"$game""$extension".mgl          #/media/fat/games/CORE/Gamedir/Game.EXTENSION.mgl
  elif [[ ${fullPath} = *_Arcade* ]]; then
    extension=".mra"
    sedPath="$rootPath""$arcadeWithGame""$extension"
  fi

  case $extension in
  ".mra") writeArcade ;;
  *) writeMgl ;;
  esac

  sed -i "/$cardNumber/d" "$confFile"
  sed -i "4i $cardNumber	echo load_core \"$sedPath\" > $misterCmd" "$confFile"
}

write_rom "$1"
