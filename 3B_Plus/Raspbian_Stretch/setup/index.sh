#!/bin/bash
set -u

# Configure system proxy
./environment/setup_environment.sh

# Setup NTP timesync
./timesyncd/setup_timesyncd.sh

# Setup APT proxy
./apt/setup_apt.sh

./dnsmasq/install_dnsmasq.sh
./snapd/install_snapd.sh
./vim/install_vim.sh

./access_point/setup_access_point.sh
./server/install_server.sh
