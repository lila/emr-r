#!/bin/bash

sudo echo "deb http://streaming.stat.iastate.edu/CRAN/bin/linux/debian squeeze-cran3/" | sudo tee -a /etc/apt/sources.list
sudo gpg --keyserver pgpkeys.mit.edu --recv-key 06F90DE5381BA480
sudo gpg -a --export 06F90DE5381BA480 | sudo apt-key add -
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -t squeeze-cran3 install --yes --force-yes r-base r-base-dev
