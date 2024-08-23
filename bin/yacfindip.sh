#!/bin/bash

IP=$1

if [ -z "$IP" ] ; then
    echo missing ip
    exit 1
fi

clouds=$(yc --format json resource-manager cloud list | jq -r '.[] | .id')
for cloud_id in $clouds; do
    folders=$(yc --format json --cloud-id $cloud_id resource-manager folder list | jq -r '.[] | .name')

    for folder in $folders ; do
        yc --format json --cloud-id $cloud_id --folder-name $folder vpc address list | jq -r '.[] | select(.type=="EXTERNAL") | .external_ipv4_address.address' | grep -q $IP
        if [ $? -eq 0 ]; then
            echo found $IP in $folder @ https://console.yandex.cloud/cloud/$cloud_id
            exit
        fi
    done
done

