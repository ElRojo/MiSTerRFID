#!/bin/bash

ttydev="/dev/ttyUSB0"

WAITEND=$((SECONDS + 30))
while ! [ -c "${ttydev}" ] && [ ${SECONDS} -lt ${WAITEND} ]; do
	sleep 0.1
done

if [ -c "${ttydev}" ]; then
	export PATH="/media/fat/Scripts/rfid_util:$PATH"
	stty 9600 -F "${ttydev}" raw -echo
	bash <"${ttydev}"
fi
