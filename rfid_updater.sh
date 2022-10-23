#!/bin/bash
{
    CURL_RETRY="--connect-timeout 15 --max-time 600 --retry 3 --retry-delay 5"
    ALLOW_INSECURE_SSL="true"
    SCRIPT_PATH=/media/fat/Scripts/rfid_updater.sh
    SCRIPTS_FOLDER=/media/fat/Scripts
    SSL_SECURITY_OPTION=""
    UPDATER_DOWNLOAD=("rfid_updater.sh")
    ROOT_DOWNLOADS=("rfid_process.sh" "rfid_write.sh" "serial_listen.sh")
    UTIL_DOWNLOADS=("game_list.conf" "neoGeo_games.sh" "rfid_write.mp3" "rfid_process.mp3" "write_tag.mp3")
    REPOSITORY_URL="https://raw.githubusercontent.com/ElRojo/MiSTerRFID"
    USER_STARTUP=/media/fat/linux/user-startup.sh
    LOGFILE=/media/fat/Scripts/rfid_util/rfid_log.txt

    mister_rfid() {
        if [ -e "/media/fat/Scripts/rfid_util" ]; then
            UTIL_DOWNLOADS=("${UTIL_DOWNLOADS[@]:1}")
            echo -e "Updating MiSTerRFID!\n"
            mv "$SCRIPTS_FOLDER"/rfid_write.sh "$SCRIPTS_FOLDER"/rfid_util/rfid_write.bak
            echo -e "A backup of rfid_write.sh has been created in\n${SCRIPTS_FOLDER}/rfid_util/rfid_write.bak\n"
            echo -e "############################################################\n"
            sleep 2
        else
            mkdir ""$SCRIPTS_FOLDER"/rfid_util"
            echo -e "Installing MiSTerRFID!\n"
            echo -e "############################################################\n"
            sleep 2
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

        echo "Starting download..."
        echo -e "${REPOSITORY_URL}\n"
        for i in "${ROOT_DOWNLOADS[@]}"; do
            curler ""${SCRIPTS_FOLDER}"/"${i}"" "${REPOSITORY_URL}/main/fat/media/Scripts/${i}"
        done
        for i in "${UTIL_DOWNLOADS[@]}"; do
            curler ""${SCRIPTS_FOLDER}/rfid_util"/"${i}"" "${REPOSITORY_URL}/main/fat/media/Scripts/rfid_util/${i}"
        done
    }

    curler() {
        echo "Downloading ${i}"
        curl \
            ${CURL_RETRY} --silent --show-error \
            ${SSL_SECURITY_OPTION} \
            --fail \
            --location \
            -o "$1" \
            "$2"
    }
    mister_log_enabler() {
        echo -e "\n############################################################"
        echo "Enabling log_file_entry in MiSTer.ini"
        echo -e "############################################################\n"
        sed -i "s/log_file_entry=0/log_file_entry=1/g" "/media/fat/MiSTer.ini"
        echo "Enabled in MiSTer.ini"
        if [ -e "/media/fat/MiSTer_alt_1.ini" ]; then
            echo -e "\n############################################################"
            echo "Enabling log_file_entry in alt ini files."
            echo -e "############################################################\n"
            for ((i = 1; i < 4; i++)); do
                if [ -e "/media/fat/MiSTer_alt_$i.ini" ]; then
                    sed -i "s/log_file_entry=0/log_file_entry=1/g" "/media/fat/MiSTer_alt_$i.ini"
                    echo "Enabled in MiSTer_alt_$i.ini"
                fi
            done
            echo -e "\n############################################################\n"
        fi
    }

    user_startup() {
        if [ ! -e ${USER_STARTUP} ]; then
            echo -e "user-startup.sh not found.\n"
            create_user_startup
        else
            userStartupLine=$(grep -n "screen -d -m -t rfid sh /media/fat/Scripts/serial_listen.sh" ${USER_STARTUP})
            if [[ $userStartupLine != *"screen -d -m -t rfid"* ]]; then
                echo -e "user-startup.sh exists, adding rfid line..."
                echo "screen -d -m -t rfid sh /media/fat/Scripts/serial_listen.sh" >>${USER_STARTUP}
            fi
        fi

    }

    create_user_startup() {
        echo "############################################################"
        echo "Creating user-startup.sh"
        echo "############################################################"
        touch ${USER_STARTUP}
        {
            echo '#!/bin/sh'
            echo '"***" $1 "***"'
            echo 'screen -d -m -t rfid sh /media/fat/Scripts/serial_listen.sh'
        } >>${USER_STARTUP}
    }
    echo -e "========================================================\n\nThanks for using MiSTer RFID!\nPlease report any bugs here:\nhttps://github.com/ElRojo/MiSTerRFID/issues\n\n========================================================\n"
    sleep 2
    mister_rfid
    mister_log_enabler
    user_startup
    for i in "${UPDATER_DOWNLOAD[@]}"; do
        echo ""
        curler "${SCRIPT_PATH}.new" "${REPOSITORY_URL}/main/${i}"
    done
    mv ${SCRIPT_PATH}.new ${SCRIPT_PATH}
    echo -e "\n🎉Complete!🎉\n"
    echo -e "Power off your MiSTER, plug in your RFID reader,\nand power the MiSTER back on to begin using it!\n"
    sleep 2
    exit 0
}
