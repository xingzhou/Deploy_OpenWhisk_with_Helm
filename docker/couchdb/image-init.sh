#!/bin/bash
set -ex

# Always clone the latest version of OpenWhisk
git clone https://github.com/apache/incubator-openwhisk /openwhisk

pushd /openwhisk
  # Install ansible requirements
  ./tools/ubuntu-setup/pip.sh

  sudo pip install -U pip

  # upgrade cffi for ansible error on Debian Jesse
  pip install --upgrade cffi
  sudo pip install markupsafe
  sudo pip install ansible==2.3.0.0

  sudo pip install -U pyopenssl
popd
