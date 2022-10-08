#!/bin/bash

source /media/fat/Scripts/rfid_util/neoGeo_games.sh

write_rom() {

	#==========================================
	#             Env Variables              #
	#==========================================
	cardNumber="$1"
	mountType="f"
	indexVal="0"
	confFile=/media/fat/Scripts/rfid_util/game_list.conf
	coreName=$(cat /tmp/CORENAME) #CORE
	startPath=$(cat /tmp/STARTPATH)
	fullPath=$(cat /tmp/FULLPATH)         #games/CORE
	game=$(cat /tmp/CURRENTPATH)          #Game
	processedName=$(cat /tmp/CURRENTPATH) #Game temporary for testing
	rootPath=/media/fat/
	gameLocation="$rootPath""$fullPath"/"$game"             #/media/fat/games/CORE/Game #was absoluteGameDir
	gameWithDir="$gameLocation"/"$game"                     #/media/fat/games/CORE/Game/Game
	fullCoreGamesDir="$rootPath""$fullPath"                 #/media/fat/games/CORE
	rbfFile=_$(cat /tmp/STARTPATH | awk -F _ '{printf $2}') #_Folder/CORE

	writeMgl() {
		if [ ! -f "$SedPath" ]; then
			echo "<mistergamedescription><rbf>"$rbfFile"</rbf><file delay=\"2\" type=\"$mountType\" index=\"$indexVal\" path=\""$relativeGameDir"\"/></mistergamedescription>" >"$sedPath"
		fi
	}

	writeArcade() {
		sedPath="$startPath" #/media/fat/_Arcade/game.mra
	}

	prepareMgl() {

		isDir() {
			if [[ -d $1 ]]; then
				return 0
			else
				gameLocation="$fullCoreGamesDir" #/media/fat/games/CORE/Game -> #/media/fat/games/CORE
				return 1
			fi
		}

		extensionFinder() {
			extFinder=$(ls -1 "$1"/)
			case "$2" in
			"Genesis") case "$extFinder" in
				*".bin"*) extension=".bin" ;;
				*".gen"*) extension=".gen" ;;
				*".md"*) extension=".md" ;;
				esac ;;
			"GAMEBOY") case "$extFinder" in
				*".bin"*) extension=".bin" ;;
				*".gbc"*) extension=".gbc" ;;
				*".gb"*) extension=".gb" ;;
				esac ;;
			"GBA") case "$extFinder" in
				*".gba"*) extension=".gba" ;;
				esac ;;
			"PSX") case "$extFinder" in
				*".cue"*) extension=".cue" ;;
				*".chd"*) extension=".chd" ;;
				esac ;;
			"SGB") case "$extFinder" in
				*".gbc"*) extension=".gbc" ;;
				*".gb"*) extension=".gb" ;;
				esac ;;
			"SNES") case "$extFinder" in
				*".sfc"*) extension=".sfc" ;;
				*".smc"*) extension=".smc" ;;
				*".bin"*) extension=".bin" ;;
				*".bs"*) extension=".bs" ;;
				*".spc"*) extension=".spc" ;;
				*".zip"*) extension".zip" ;;
				esac ;;
			"MegaCD") case "$foundGame" in
				*".cue"*) extension=".cue" ;;
				*".chd"*) extension=".chd" ;;
				esac ;;
			*) case "$extFinder" in
				*".srm"*) extension=".srm" ;;
				*".neo"*) extension=".neo" ;;
				*) extension="None Found!" ;;
				esac ;;
			*) extension="No core match!" ;;
			esac
		}

		gameSanitizer() {
			if [[ "$1" = NEOGEO ]]; then
				for i in "${!neoGeoEnglish[@]}"; do
					if [[ "$(echo "$game" | grep -w "${neoGeoEnglish[$i]}")" ]]; then #This code pulled from https://github.com/mrchrisster/MiSTer_SAM/blob/main/MiSTer_SAM_on.sh. Awesome idea!
						processedName="$i"
					fi
				done
			elif [[ "$1" = SNES || Genesis ]]; then
				game="${game%.*}"
				processedName="$game"
			else
				:
			fi
		}

		mglPreparer() {
			case "$1" in
			"Amiga") mountType="f" indexVal=0 ;;
			"ATARI5200") mountType="f" indexVal=1 ;;
			"ATARI7800") mountType="f" indexVal=1 ;;
			"ATARI800") mountType="f" ;;
			"AtariLynx") mountType="f" indexVal=1 ;;
			"C64") mountType="f" indexVal=1 ;;
			"GAMEBOY") mountType="f" indexVal=0 ;;
			"GAMEBOY2P") mountType="f" indexVal=0 ;;
			"GBA") mountType="f" indexVal=0 ;;
			"GBA2P") mountType="f" indexVal=0 ;;
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

		gameSanitizer "$coreName"

		isDir "$gameLocation"

		isDirRtn=$?

		extensionFinder "$gameLocation" "$coreName"

		mglPreparer "$coreName"

		if [ "$isDirRtn" -eq 0 ]; then
			sedPath="$gameWithDir".mgl                  #/media/fat/games/CORE/Game/Game.mgl
			relativeGameDir="$game"/"$game""$extension" #Game/Game.ext
		else
			sedPath="$gameLocation"/"$game".mgl          #/media/fat/games/CORE/Game.mgl
			relativeGameDir="$processedName""$extension" #Game.ext
		fi

		writeMgl
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
