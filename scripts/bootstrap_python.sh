#!/bin/bash

TOPDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
pushd ${TOPDIR}

#
# Set up Python env
#

pushd python_env

virtualenv .
source bin/activate

# No RDF in pip (it's rdfutils)

for i in 'setuptools>=0.7' Paste PasteDeploy PasteScript rdfutils cssselect \
         transifex-client pysocks
do
    pip2 install $i
done

################################################################################
# Avoid:
# pkg_resources.ContextualVersionConflict: (idna 2.2 (/usr/lib/python2.7/dist-packages), Requirement.parse('idna<2.7,>=2.5'), set(['requests']))
pip2 install requests
################################################################################

################################################################################
# More missing dependencies
pip2 install sphinx routes webob beautifulsoup4 waitress
#pip2 install unittest2 zope.component
################################################################################

# On Ubuntu, virtualenv setups don't "see" dist-packages, which is
# where Ubuntu-packaged modules go. This works around that problem:

echo "/usr/lib/python2.7/dist-packages/" \
     > lib/python2.7/site-packages/dist-packages.pth

#
# Check out and set up each Python module
#

mkdir -p src
pushd src

REPOS=(cc.i18n cc.licenserdf cc.license cc.engine)
for i in "${REPOS[@]}"
do
    if [ -d "${i}" ]
    then
        pushd "${i}"
        git pull
        popd
    else
        git clone "https://github.com/creativecommons/${i}.git"
    fi
    pushd "${i}"
    python2 bootstrap.py -v 2.1.1
    bin/buildout
    python2 setup.py install
    popd
done

popd # to python_env
# OR
#pip2 install git+https://github.com/creativecommons/cc.engine

#
# compile_mo & transstats are needed by cc.engine at runtime, run them now
#

bin/compile_mo
bin/transstats

popd # to topdir

#
# Generate ccengine.fcgi
#

sed -e "s|@env_dir@|${TOPDIR}/python_env|" \
    < "python_env/bin/ccengine.fcgi.in" \
    > "python_env/bin/ccengine.fcgi"

chmod 755 python_env/bin/ccengine.fcgi

#
# Support the semantic web
#

ln -s ${TOPDIR}/python_env/src/cc.licenserdf \
   ${TOPDIR}/docroot/cc.licenserdf
ln -s ${TOPDIR}/docroot/cc.licenserdf/cc/licenserdf/rdf \
   ${TOPDIR}/docroot/rdf
ln -s ${TOPDIR}/docroot/cc.licenserdf/cc/licenserdf/licenses \
   ${TOPDIR}/docroot/license_rdf

popd # to original

#
# Set up transifex
#
