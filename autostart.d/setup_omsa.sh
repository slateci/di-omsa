#!/bin/bash
if [[ -f /opt/dell/srvadmin/sbin/srvadmin-services.sh ]]; then
  echo " * setting up Dell GPG keys"
  curl -s https://linux.dell.com/repo/hardware/dsu/copygpgkeys.sh | bash

  echo " * starting OMSA server"
  sudo /opt/dell/srvadmin/sbin/srvadmin-services.sh start
else
  echo " * OMSA is not installed, skipping OMSA setup"
fi
