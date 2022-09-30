#!/bin/bash

mountType="f"
indexVal="0"
misterCmd=/dev/MiSTer_cmd
confFile=/media/fat/Scripts/rfid_util/game_list_rfid.conf
coreName=$(cat /tmp/CORENAME)
startPath=$(cat /tmp/STARTPATH)
fullPath=$(cat /tmp/FULLPATH)
game=$(cat /tmp/CURRENTPATH)
rootPath=/media/fat/
absoluteGameDir="$rootPath""$fullPath"/"$game"          #/media/fat/games/CORE/Gamedir
neoGameDir="$rootPath""$fullPath"                       #/media/fat/games/NEOGEO
rbfFile=_$(cat /tmp/STARTPATH | awk -F _ '{printf $2}') #_Folder/CORE


declare -A gamePaths=(
  ["psxPath"]=/media/fat/games/PSX/"$game"
  ["neoGeoPath"]=/media/fat/games/NEOGEO
  ["nesPath"]=/media/fat/games/NES
  
)
