#!/bin/bash

source /media/fat/Scripts/rfid_util/neoGeo_games.sh
write_rom() {

  #==========================================
  #               Needed Vars               #
  #==========================================
  cardNumber="$1"
  fileFailed=0
  neoGeoName=""
  rootPath=/media/fat
  confFile=/media/fat/Scripts/rfid_util/game_list.conf
  coreName=$(cat /tmp/CORENAME)
  startPath=$(cat /tmp/STARTPATH)
  fullPath=$(cat /tmp/FULLPATH)
  game=$(cat /tmp/CURRENTPATH)
  fullPathToCoreGamesDir="$rootPath"/"$fullPath"         # /media/fat/games/CORE
  fullPathToGameLocation="$rootPath"/"$fullPath"/"$game" # /media/fat/games/CORE/Game
  rbfFile=_$(cat /tmp/STARTPATH | awk -F _ '{printf $2}')
  #=========================================#

  findIt() {
    if [[ $findItRan != "1" ]]; then
      foundGame=$(find "$fullPathToCoreGamesDir" -name "$1*" -type f -print | grep -v ".mgl")
      findItRan="1"
    fi
  }

  prepFinalPaths() {
    #picks a game out of list in case of multiple found results
    if [[ "$hasExtension" = "0" ]]; then
      fullFoundGamePath=$(echo "$foundGame" | grep -m 1 "$extension")
    else
      fullFoundGamePath="$fullPathToGameLocation"
    fi

    fullFoundGamePathNoExt="${fullFoundGamePath%.*}"

    if [[ "$coreName" = NEOGEO ]]; then
      processedName="$neoGeoName"
      sedPath="$fullPathToGameLocation".mgl
    else
      processedName=$(echo "$fullFoundGamePathNoExt" | awk -F "$coreName"/ '{printf $2}')
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
    sedPath="$startPath"
  }

  prepareMgl() {

    extensionFinder() {
      if [[ $hasExtension = "0" ]]; then
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
        "NEOGEO") extension=".neo" ;;
        *) case "$foundGame" in
          *) extension="No core or extension found!" ;;
          esac ;;
        esac
      fi
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

    neoGeoFileFixer() {
      if [[ ${coreName} = NEOGEO ]]; then
        for i in "${!neoGeoEnglish[@]}"; do
          if [[ "$(echo "$game" | grep -x "${neoGeoEnglish[$i]}")" ]]; then #This code pulled from https://github.com/mrchrisster/MiSTer_SAM/blob/main/MiSTer_SAM_on.sh. Awesome idea!
            neoGeoName="$i"
            findIt "$neoGeoName"
            break
          fi
        done
        if [[ "$neoGeoName" = "" ]]; then
          echo ""$game" not found in neoGeo_games list!"
          fileFailed=1
        fi
      fi
    }

    extensionChecker() {
      case $1 in
      "Genesis") case "$game" in
        *".bin") hasExtension="1" extension=".bin" ;;
        *".gen") hasExtension="1" extension=".gen" ;;
        *".md") hasExtension="1" extension=".md" ;;
        *) hasExtension="0" ;;
        esac ;;
      "GAMEBOY") case "$game" in
        *".bin") hasExtension="1" extension=".bin" ;;
        *".gbc") hasExtension="1" extension=".gbc" ;;
        *".gb") hasExtension="1" extension=".gb" ;;
        *) hasExtension="0" ;;
        esac ;;
      "GBA") case "$game" in
        *".gba") hasExtension="1" extension=".gba" ;;
        *) hasExtension="0" ;;
        esac ;;
      "SGB") case "$game" in
        *".gbc") hasExtension="1" extension=".gbc" ;;
        *".gb") hasExtension="1" extension=".gb" ;;
        *) hasExtension="0" ;;
        esac ;;
      "SNES") case "$game" in
        *".sfc") hasExtension="1" extension=".sfc" ;;
        *".smc") hasExtension="1" extension=".smc" ;;
        *".bin") hasExtension="1" extension=".bin" ;;
        *".bs") hasExtension="1" extension=".bs" ;;
        *".spc") hasExtension="1" extension=".spc" ;;
        *".zip") hasExtension="1" extension=".zip" ;;
        *) hasExtension="0" ;;
        esac ;;
      "PSX") case "$game" in
        *".cue") hasExtension="1" extension=".cue" ;;
        *".chd") hasExtension="1" extension=".chd" ;;
        *) hasExtension="0" ;;
        esac ;;
      "MegaCD") case "$game" in
        *".cue") hasExtension="1" extension=".cue" ;;
        *".chd") hasExtension="1" extension=".chd" ;;
        *) hasExtension="0" ;;
        esac ;;
      *) hasExtension="0" ;;
      esac
    }

    neoGeoFileFixer "$coreName"

    extensionChecker "$coreName"

    findIt "$game"

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
if [ ${fileFailed} = "1" ]; then
  mpg123 -q /media/fat/Scripts/rfid_util/err.mp3
elif [ ${fileFailed} = "0" ]; then
  mpg123 -q /media/fat/Scripts/rfid_util/rfid_write.mp3
fi
