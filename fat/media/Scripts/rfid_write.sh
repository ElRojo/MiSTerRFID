#!/bin/bash

source /media/fat/Scripts/rfid_util/neoGeo_games.sh

rootDirs=(
  "/media/usb0/games"
  "/media/usb1/games"
  "/media/usb2/games"
  "/media/usb3/games"
  "/media/usb4/games"
  "/media/usb5/games"
  "/media/fat/cifs/games"
  "/media/fat/games"
)

for d in ${rootDirs[@]}; do
  if [ -d "$d" ]; then
    gamesDir="$d"
  fi
done

write_rom() {

  #==========================================
  #               Needed Vars               #
  #==========================================
  cardNumber="$1"
  confFile=/media/fat/Scripts/rfid_util/game_list.conf
  coreName=$(cat /tmp/CORENAME) #CORE
  startPath=$(cat /tmp/STARTPATH)
  fullPath=$(cat /tmp/FULLPATH) #games/CORE
  game=$(cat /tmp/CURRENTPATH)
  fullCorePath="$gamesDir"/"$coreName"                    # /media/fat/games/CORE
  fullGamePath="$fullCorePath"/"$game"                    # /media/fat/games/CORE/Game
  coreFullGamesPath="$fullCorePath""$fullPath"            # /media/fat/games/CORE
  rbfFile=_$(cat /tmp/STARTPATH | awk -F _ '{printf $2}') # _Folder/CORE
  #=========================================#

  findIt() {
    foundGame=$(find "$fullCorePath" -name "$1.*" -print) #/media/fat/games/CORE/Game
  }

  prepFinalPaths() {
    fullFoundGamePath=$(echo "$foundGame" | grep -m 1 "$extension")
    fullFoundGamePathNoExt="${fullFoundGamePath%.*}"
    if [[ "$coreName" = NEOGEO ]]; then
      processedName="$neoGeoName"
      sedPath="$fullGamePath".mgl
    else
      processedName=$(echo "$fullFoundGamePathNoExt" | awk -F "$fullCorePath"/ '{printf $2}')
      sedPath="$fullFoundGamePathNoExt".mgl
    fi

    relativeGameDir="$processedName""$extension"

    writeMgl "$sedPath" "$relativeGameDir"
  }

  writeMgl() {
    if [ ! -f "$1" ]; then
      echo "<mistergamedescription><rbf>"$rbfFile"</rbf><file delay=\"2\" type=\"$mountType\" index=\"$indexVal\" path=\""$2"\"/></mistergamedescription>" >"$1"
    fi
  }

  writeArcade() {
    sedPath="$startPath" #/media/fat/_Arcade/game.mra
  }

  prepareMgl() {

    extensionFinder() {
      case $coreName in
      "Genesis") case "$foundGame" in
        *".bin"*) extension=".bin" ;;
        *".gen"*) extension=".gen" ;;
        *".md"*) extension=".md" ;;
        esac ;;
      "GAMEBOY") case "$foundGame" in
        *".bin"*) extension=".bin" ;;
        *".gbc"*) extension=".gbc" ;;
        *".gb"*) extension=".gb" ;;
        esac ;;
      "GBA") case "$foundGame" in
        *".gba"*) extension=".gba" ;;
        esac ;;
      "SGB") case "$foundGame" in
        *".gbc"*) extension=".gbc" ;;
        *".gb"*) extension=".gb" ;;
        esac ;;
      "SNES") case "$foundGame" in
        *".sfc"*) extension=".sfc" ;;
        *".smc"*) extension=".smc" ;;
        *".bin"*) extension=".bin" ;;
        *".bs"*) extension=".bs" ;;
        *".spc"*) extension=".spc" ;;
        *".zip"*) extension=".zip" ;;
        esac ;;
      "PSX") case "$foundGame" in
        *".cue"*) extension=".cue" ;;
        *".chd"*) extension=".chd" ;;
        esac ;;
      "MegaCD") case "$foundGame" in
        *".cue"*) extension=".cue" ;;
        *".chd"*) extension=".chd" ;;
        esac ;;
      *) case "$foundGame" in
        *".srm"*) extension=".srm" ;;
        *".neo"*) extension=".neo" ;;
        *) extension="None Found!" ;;
        esac ;;
      *) extension="No core match!" ;;
      esac
    }

    mglPreparer() {
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
    }

    isNeoGeo() {
      if [[ ${1} = NEOGEO ]]; then
        for i in "${!neoGeoEnglish[@]}"; do
          if [[ "$(echo "$game" | grep -w "${neoGeoEnglish[$i]}")" ]]; then #This code pulled from https://github.com/mrchrisster/MiSTer_SAM/blob/main/MiSTer_SAM_on.sh. Awesome idea!
            neoGeoName="$i"
            findIt "$neoGeoName"
          fi
        done
      else
        findIt "$game"
      fi
    }

    isNeoGeo "$coreName"

    extensionFinder "$coreName"

    mglPreparer "$coreName"

    prepFinalPaths

  }

  if [[ ${startPath} = *".mgl" ]]; then
    return
  fi
  if [[ ${fullPath} != *_Arcade* ]]; then
    prepareMgl
  elif [[ ${fullPath} = *_Arcade* ]]; then
    writeArcade

  fi
  sed -i "/$cardNumber/d" "$confFile"
  sed -i "4i $cardNumber	echo load_core \"$sedPath\" > /dev/MiSTer_cmd" "$confFile"
}

write_rom "$1"
