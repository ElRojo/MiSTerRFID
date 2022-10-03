#!/bin/bash

source rfid_util/rfid_neoGeo_games.sh

write_rom() {

	#==========================================
	#             Env Variables              #
	#==========================================
	cardNumber="$1"
	mountType="f"
	indexVal="0"
	foundGame=""
	misterCmd=/dev/MiSTer_cmd
	confFile=/media/fat/Scripts/rfid_util/game_list_rfid.conf
	coreName=$(cat /tmp/CORENAME) #CORE
	startPath=$(cat /tmp/STARTPATH)
	fullPath=$(cat /tmp/FULLPATH)         #games/CORE
	game=$(cat /tmp/CURRENTPATH)          #Game
	processedName=$(cat /tmp/CURRENTPATH) #Game temporary for testing
	rootPath=/media/fat/
	gameLocation="$rootPath""$fullPath"/"$game"             #/media/fat/games/CORE/Game #was absoluteGameDir
	gameWithDir="$gameLocation"/"$game"                     #/media/fat/games/CORE/Game/Game
	relativeGamesDir="$rootPath""$fullPath"                 #/media/fat/games/CORE
	rbfFile=_$(cat /tmp/STARTPATH | awk -F _ '{printf $2}') #_Folder/CORE

	findIt() {
		foundGame=$(find "$relativeGamesDir" -name "$1.*" -print) #/media/fat/games/CORE/Game
		return "$foundGame"
	}

	writeMgl() {
		if [ ! -f "$SedPath" ]; then
			echo "<mistergamedescription><rbf>"$rbfFile"</rbf><file delay=\"2\" type=\"$mountType\" index=\"$indexVal\" path=\""$relativeGameDir"\"/></mistergamedescription>" >"$sedPath"
		fi
	}

	writeArcade() {
		sedPath="$startPath" #/media/fat/_Arcade/game.mra
	}

	prepareMgl() {

		findIt "$game"

		isNeoGeo() {
			if [[ ${1} = NEOGEO ]]; then
				for i in "${!neoGeoEnglish[@]}"; do
					if [[ "$(echo "$game" | grep -w "${neoGeoEnglish[$i]}")" ]]; then #This code pulled from https://github.com/mrchrisster/MiSTer_SAM/blob/main/MiSTer_SAM_on.sh. Awesome idea!
						processedName="$i"
					fi
				done
			fi
		}

		isNeoGeo "$coreName"

		# extension="${game##*.}" #.ext

		# case $coreName in
		# # "PSX") case "$foundGame" in
		# # 	*".cue") extension=".cue" ;;
		# # 	*".chd") extension=".chd" ;;
		# # 	esac ;;
		# # "NES") case "$foundGame" in
		# # 	*".nes") extension=".nes" ;;
		# # 	esac ;;
		# # "Genesis") case "$foundGame" in
		# # 	*".bin") extension=".bin" ;;
		# # 	*".gen") extension=".gen" ;;
		# # 	esac ;;
		# # "SNES") case "$foundGame" in
		# # 	*".sfc") extension=".sfc" ;;
		# # 	*".smd") extension=".smd" ;;
		# # 	*".srm") extension=".srm" ;;
		# # 	esac ;;
		# # "NEOGEO") case "$foundGame" in
		# # 	*".neo") extension=".neo" ;;
		# # 	esac ;;
		# esac

		case $coreName in

		"Genesis") case "$foundGame" in
			*".bin") extension=".bin" ;;
			*".gen") extension=".gen" ;;
			esac ;;
		*) case "$foundGame" in
			*".sfc") extension=".sfc" ;;
			*".smd") extension=".smd" ;;
			*".srm") extension=".srm" ;;
			*".neo") extension=".neo" ;;
			esac ;;
		esac

		# case "$foundGame" in
		# *".bin") extension=".bin" ;;
		# *".cue") extension=".cue" ;;
		# *".chd") extension=".chd" ;;
		# *".sfc") extension=".sfc" ;;
		# *".smc") extension=".smc" ;;
		# *".gen") extension=".gen" ;;
		# *".neo") extension=".neo" ;;
		# *".nes") extension=".nes" ;;
		# *".md") extension=".md" ;;
		# *) unset extension ;;
		# esac

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

		sedPath="$gameLocation"/"$game".mgl          #/media/fat/games/CORE/Game.mgl
		relativeGameDir="$processedName""$extension" #Game.ext

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
	sed -i "4i $cardNumber	echo load_core \"$sedPath\" > $misterCmd" "$confFile"
}

write_rom "$1"
