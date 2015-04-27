#!/bin/sh

gsettings set org.gnome.system.proxy.socks host '127.0.0.1'
gsettings set org.gnome.system.proxy.socks port 8844
gsettings set org.gnome.system.proxy mode 'manual'

# gsettings set org.gnome.system.proxy mode 'none' # this will disable proxy setting

# gsettings set org.gnome.system.proxy mode 'auto' # this will set the proxy automatic
