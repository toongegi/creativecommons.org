#!/bin/bash

TOPDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

#
# Install base system dependencies
# NOTE: MySQL install has been moved to bootstrap_mysql.sh
# FURTHER NOTE: python stuff should be moved out to the python env

apt-get update
if apt-get -y install `cat ${TOPDIR}/config/required_packages.txt`
then
    echo "Required packages installed, proceeding with setup."
else
    echo "Could not install required packages, aborting setup."
    exit 1
fi
