#!/bin/bash
# Disabling the script
exit 0

echo " * Setting releasever yum variable"
source /etc/os-release
echo $VERSION_ID >> /etc/yum/vars/releasever

echo " * Running Dell bootstrap to get repos"
dell_bootstrap.sh

sudo yum install srvadmin-base srvadmin-server-cli srvadmin-storage-cli -y
./setup_omsa.sh
