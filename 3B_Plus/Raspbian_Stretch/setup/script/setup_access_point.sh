#!/bin/bash
set -u

source "$(readlink -f './share/index.conf')"

# Wi-Fi Software Access Point
sudo apt install hostapd
