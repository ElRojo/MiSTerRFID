#!/bin/bash

CURL_RETRY="--connect-timeout 15 --max-time 600 --retry 3 --retry-delay 5"
ALLOW_INSECURE_SSL="true"
SCRIPT_PATH=/media/fat/Scripts/rfid_installer.sh
SCRIPTS_FOLDER=/media/fat/Scripts
SSL_SECURITY_OPTION=""
ROOT_DOWNLOADS=("rfid_process.sh" "rfid_write.sh" "serial_listen.sh")

mister_rfid() {
    if [ ! -f "/media/fat/Scripts/rfid_util" ]; then
        UTIL_DOWNLOADS=("neoGeo_games.sh")
        echo "Updating MiSTerRFID"
    else
        UTIL_DOWNLOADS=("game_list.conf" "neoGeo_games.sh")
        mkdir ""$SCRIPT_PATH"/rfid_util"
        echo "Installing MiSTerRFID"
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

    REPOSITORY_URL="https://github.com/ElRojo/MiSTerRFID"
    echo "Downloading"
    echo "${REPOSITORY_URL}"
    echo ""
    for i in ${ROOT_DOWNLOADS[@]}; do
        curl \
            ${CURL_RETRY} --silent --show-error \
            ${SSL_SECURITY_OPTION} \
            --fail \
            --location \
            -o "${SCRIPT_PATH}"/"${i}" \
            "${REPOSITORY_URL}/tree/main/fat/media/Scripts/${i}"
    done

    for i in ${UTIL_DOWNLOADS[@]}; do
        curl \
            ${CURL_RETRY} --silent --show-error \
            ${SSL_SECURITY_OPTION} \
            --fail \
            --location \
            -o "${SCRIPTS_FOLDER}/rfid_util"/"${i}" \
            "${REPOSITORY_URL}/tree/main/fat/media/Scripts/rfid_util/${i}"
    done
}

mister_rfid

exit 0
