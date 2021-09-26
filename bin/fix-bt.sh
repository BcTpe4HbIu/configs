#!/bin/zsh

devices=( "FC:E8:06:5D:E8:C3" "FC:E8:06:5E:1E:FC" "00:00:00:01:31:D9" "00:00:00:01:2E:E2" )

for device in $devices[@]
do
    connected=$(bluetoothctl info $device | grep Connected | cut -d ' ' -f 2)
    if [ "$connected" = "yes" ] ; then
        echo reconnecting to $device
        bluetoothctl disconnect $device
        sleep 1
        bluetoothctl connect $device
        sleep 5
        pactl set-card-profile bluez_card.${device//:/_} a2dp_sink
    fi
done
