#!/bin/sh

echo "***" $1 "***"
sleep 10
screen -d -m -t rfid sh /media/fat/Scripts/serial_listen.sh


