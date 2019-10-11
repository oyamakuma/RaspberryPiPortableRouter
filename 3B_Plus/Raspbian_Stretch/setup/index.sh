#!/bin/bash
set -u

declare -r WD_PATH="$(dirname "$(readlink -f "${BASH_SOURCE}")")"

source "${WD_PATH}/share/index.conf"

# Configure system proxy
"${WD_PATH}/setup_environment.sh"

# Setup NTP timesync
"${WD_PATH}/setup_timesyncd.sh"

# Setup APT proxy
"${WD_PATH}/setup_apt.sh"

"${WD_PATH}/install_dnsmasq.sh"
"${WD_PATH}/install_snapd.sh"
"${WD_PATH}/install_vim.sh"

"${WD_PATH}/setup_access_point.sh"
"${WD_PATH}/install_server.sh"
"${WD_PATH}/setup_local_CA.sh"
