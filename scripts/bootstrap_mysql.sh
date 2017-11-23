#!/bin/bash

TOPDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

#
#FIXME: The logic of this file is broken. Break out into install and configure
#

DBNAME=${1:-wordpress}
DBUSER=${2:-dbuser}
DBPASS=${3:-}
DBHOST=${4:-127.0.0.1}

MYSQL_ROOT_PASSWORD=''

#
# Install MySQL
#

debconf-set-selections "mariadb-server-10.0 mariadb-server/root_password password '${MYSQL_ROOT_PASSWORD}'"
debconf-set-selections <<< "mariadb-server-10.0 mariadb-server/root_password_again password '${MYSQL_ROOT_PASSWORD}'"
debconf-set-selections <<< "mariadb-server-10.0 mariadb-server/oneway_migration boolean true"

if apt-get -y install `cat ${TOPDIR}/config/required_packages_mysql.txt`

#
# Create a MySQL DB for WordPress
#

# run mysql to see if the root user has a password set
if mysql -h ${DBHOST} -u root -e ""
then
    mysql -h ${DBHOST} -u root mysql <<EOF
CREATE DATABASE IF NOT EXISTS ${DBNAME};
GRANT ALL ON ${DBNAME}.* TO '${DBUSER}'@'localhost' IDENTIFIED BY '${DBPASS}';
EOF
else
    echo "Enter the MySQL root password:"
    mysql -h ${DBHOST} -u root -p mysql <<EOF
CREATE DATABASE IF NOT EXISTS ${DBNAME};
GRANT ALL ON ${DBNAME}.* TO '${DBUSER}'@'localhost' IDENTIFIED BY '${DBPASS}';
EOF
fi
