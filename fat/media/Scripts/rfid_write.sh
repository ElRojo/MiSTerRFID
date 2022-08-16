write_rom()
{
    cardNumber="$1"
    runningGame=\"$(ps aux | grep .mra)\"
    get_title() {   
    trimPath=${1##*".rbf /media/fat/_Arcade/"}
    removeExtra=${trimPath%%.mra*}
    echo $removeExtra
    }
    gameTitle=$(get_title "$runningGame")

  rfidFile=rfid_process.sh
  sed -i "/$cardNumber/d" "$rfidFile"
  sed -i "13i \"$cardNumber\") "play" \"$gameTitle\" ;;" "$rfidFile"
}

write_rom "$1"

