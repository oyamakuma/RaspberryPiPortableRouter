#!/bin/bash
set -u

source "$(readlink -f './share/index.conf')"

source "$(readlink -f './timesyncd.conf')"

backup_file "${TIMESYNC_FILE}"

sudo sed -i "s/^\(#\)\(NTP=\)/\2${NTP_SERVER}/" "${TIMESYNC_FILE}"
sudo systemctl daemon-reload
sudo systemctl restart systemd-timesyncd.service
