#!/bin/bash
set -u

source "$(readlink -f './share/index.conf')"

sudo apt install apache2 mariadb-server
