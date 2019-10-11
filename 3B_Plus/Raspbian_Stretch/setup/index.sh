#!/bin/bash
set -u

declare -r WD_PATH="$(dirname "$(readlink -f "${BASH_SOURCE}")")"

source "${WD_PATH}/share/index.conf"

# Configure system proxy
./setup_environment.sh

# Setup NTP timesync
./setup_timesyncd.sh

# Setup APT proxy
./setup_apt.sh

./install_dnsmasq.sh
./install_snapd.sh
./install_vim.sh

./setup_access_point.sh
./install_server.sh
./setup_local_CA.sh
