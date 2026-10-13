#!/bin/bash

GW_TIMO=192.168.1.1
GW_ONO=192.168.25.1

route -n |grep "^0.0.0.0"|grep -q $GW_TIMO

if [ $? -eq 1 ]; then
    echo "Canviant d'ono a timofonica"
    sudo route del default gw $GW_ONO
    sudo route add default gw $GW_TIMO
else
    echo "Canviant de timofonica a ono"
    sudo route del default gw $GW_TIMO
    sudo route add default gw $GW_ONO
fi
