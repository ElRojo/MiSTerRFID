#!/bin/sh

echo "***" $1 "***"
screen -d -m -t rfid sh /media/fat/Scripts/rfid_util/serial_listen.sh
