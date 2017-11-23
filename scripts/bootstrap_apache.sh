#!/bin/bash

TOPDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

HOSTNAME=${1:-creativecommons.org}

#
# Configure Apache
#

function config_conf {
    FILE="${1}"
    HOST="${2}"
    PORT="${3}"
    perl -p -i -e "s/\\$\{port\}/${PORT}/g" "${FILE}"
    perl -p -i -e "s/\\$\{host\}/${HOST}/g" "${FILE}"
    perl -p -i -e "s/\\$\{proto\}/${PROTO}/g" "${FILE}"
    perl -p -i -e "s|\\$\{dir\}|${TOPDIR}|g" "${FILE}"
    perl -p -i -e "s|\\$\{logdir\}|/var/log/apache2/${HOST}|g" "${FILE}"
}

HTTPSCONF="/etc/apache2/sites-available/${HOSTNAME}.conf"
cp ${TOPDIR}/config/apache.conf "${HTTPSCONF}"
config_conf "${HTTPSCONF}" "${HOSTNAME}" "${PORT}"

# 2. Create logging directory

mkdir -p /var/log/apache2/${HOSTNAME}
chown root.adm /var/log/apache2/${HOSTNAME}
chmod 750 /var/log/apache2/${HOSTNAME}

# 3. Enable mods and site

for i in macro php5 rewrite fcgid headers
do
    a2enmod $i
done

if [ "${PROTO}" == "https" ]
then
    a2enmod ssl
fi

a2ensite ${HOSTNAME}

# 4. Restart Apache

service apache2 restart
