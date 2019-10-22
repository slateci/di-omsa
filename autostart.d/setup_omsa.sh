#!/bin/bash
echo " * Setting releasever yum variable"
source /etc/os-release
echo $VERSION_ID >> /etc/yum/vars/releasever

echo " * Running Dell bootstrap to get repos"
dell_bootstrap.sh

yum install centos-release -y
# yum install srvadmin-base srvadmin-server-cli srvadmin-storage-cli -y

if [[ -f /opt/dell/srvadmin/sbin/srvadmin-services.sh ]]; then
  echo " * setting up Dell GPG keys"
  curl -s https://linux.dell.com/repo/hardware/dsu/copygpgkeys.sh | bash

  echo " * starting OMSA server"
  sudo /opt/dell/srvadmin/sbin/srvadmin-services.sh start
else
  echo " * OMSA is not installed, skipping OMSA setup"
fi
