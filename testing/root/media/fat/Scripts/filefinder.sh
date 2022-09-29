#!/bin/bash
export PATH="/testing/root:$PATH"
cardNumber="$1"
mountType="f"
indexVal="0"
misterCmd=/dev/MiSTer_cmd
confFile=/media/fat/Scripts/game_list_rfid.conf
coreName=$(cat ./tmp/CORENAME)
startPath=$(cat ./tmp/STARTPATH)
fullPath=$(cat ./tmp/FULLPATH)
game=$(cat ./tmp/CURRENTPATH)
echo $game
rootPath=./media/fat/
fullGameDir="$rootPath""$fullPath"/"$game"              #/media/fat/games/CORE/Gamedir
rbfFile=_$(cat /tmp/STARTPATH | awk -F _ '{printf $2}') #_Folder/CORE

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
echo $extension
