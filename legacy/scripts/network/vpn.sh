#!/bin/bash

sudo route del -net 192.168.1.0/24
sudo openvpn "../VPN\ Genar.tblk/config.ovpn"
