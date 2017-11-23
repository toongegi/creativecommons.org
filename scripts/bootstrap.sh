#!/bin/bash

TOPDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

function usage {
    echo "Usage: $0 <hostname> [db name] [db user] [db user password] [db host]"
    exit 1
}
[ -z "$1" ] && usage;

HOST="${1:-creativecommons.org}"
DBNAME="${2:-wordpress}"
DBUSER="${3:-}"
DBPASS="${4:-}"
DBHOST="${5:-}"

${TOPDIR}/scripts/bootstrap_os.sh
${TOPDIR}/scripts/bootstrap_python.sh
${TOPDIR}/scripts/bootstrap_apache.sh "${HOST}"
if [ "${DBUSER}" != "" ]
then
    ${TOPDIR}/scripts/bootstrap_mysql.sh \
             "${DBNAME}" "${DBUSER}" "${DBPASS}" "${DBHOST}"
    ${TOPDIR}/scripts/bootstrap_wordpress.sh \
             "${DBNAME}" "${DBUSER}" "${DBPASS}" "${DBHOST}"
fi
