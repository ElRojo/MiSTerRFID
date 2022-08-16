#!/bin/bash

play() {
        echo "load_core /media/fat/_Arcade/"$1".mra" > /Users/conner/Desktop/mister.txt  
}

ha_cmd() {
        TOKEN="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJkYmY4ZmIxMWEyNjU0MzVkYmZhODY3NjA0YWIwNTc5OCIsImlhdCI6MTY2MDQ1NjI0NSwiZXhwIjoxOTc1ODE2MjQ1fQ.3Lvgl5ke4m55NNQxnLsEQSMM7OEkyWvL5mtTve6VnhE"
        curl -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d $1 $2 
}

case "$1" in 

esac
