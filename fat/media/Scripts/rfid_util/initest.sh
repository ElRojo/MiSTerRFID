declare -a iniArr
mister_log_enabler() {
    for configFile in "./test/*.ini"; do
        iniArr=("${configFiles[@]}" ${configFile})
    done
    echo -e "\n############################################################"
    echo "${TXTBOLD}Enabling log_file_entry in configuration file(s)${TXTNORMAL}"
    echo -e "############################################################\n"
    for configFile in ${iniArr[@]}; do
        logFileStringChk=$(grep -n "log_file_entry" ${configFile})
        if [[ ! $logFileStringChk ]]; then
            echo "${configFile} is not a config file"
        else
            sed -i "s/log_file_entry=0/log_file_entry=1/g" ${configFile}
            echo -e "\033[2m- Enabled in $(basename ${configFile})\033[0m"
        fi
    done
    echo -e "\n############################################################\n"

}
mister_log_enabler
