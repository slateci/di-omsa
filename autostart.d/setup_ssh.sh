#!/bin/bash
echo " * adding ssh keys"
cd ~
mkdir -p .ssh
if [[ -f ".ssh/authorized_keys" ]]; then
  rm -f .ssh/authorized_keys
fi

git clone https://github.com/slateci/discovery-image-keys.git
cp discovery-image-keys/authorized_keys .ssh/authorized_keys
chmod 600 .ssh/authorized_keys
rm -rf discovery-image-keys
