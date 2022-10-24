CURL_RETRY="--connect-timeout 15 --max-time 600 --retry 3 --retry-delay 5"
ALLOW_INSECURE_SSL="true"
SSL_SECURITY_OPTION=""
BRANCH="main"

curler() {
    curl \
        ${CURL_RETRY} --silent --show-error \
        ${SSL_SECURITY_OPTION} \
        --fail \
        --location \
        -o "$1" \
        "$2"
}

update_updater() {
    echo ""
    curler "/media/fat/Scripts/rfid_util/update.sh" "https://raw.githubusercontent.com/ElRojo/MiSTerRFID/${BRANCH}/fat/media/Scripts/rfid_util/update.sh"
}
echo "Downloading latest update file..."
if [ -e /media/fat/Scripts/rfid_util/update.sh ]; then
    rm /media/fat/Scripts/rfid_util/update.sh
fi
curl ${CURL_RETRY} --silent --show-error "https://github.com" >/dev/null 2>&1
case $? in
0) ;;

60)
    if [[ "${ALLOW_INSECURE_SSL}" == "true" ]]; then
        SSL_SECURITY_OPTION="--insecure"
    else
        echo "CA certificates need"
        echo "to be fixed for"
        echo "using SSL certificate"
        echo "verification."
        echo "Please fix them"
        exit 2
    fi
    ;;
*)
    echo "No Internet connection"
    exit 1
    ;;
esac
update_updater
source /media/fat/Scripts/rfid_util/update.sh
wait
rm /media/fat/Scripts/rfid_util/update.sh
echo -e "\nComplete!\n"
echo -e "Power off your MiSTER, plug in your RFID reader,\nand power the MiSTER back on to begin using it!\n"
exit 0
