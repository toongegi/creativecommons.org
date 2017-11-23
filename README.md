OS-Level Install
================

To set up the Python environment on a new server:

apt install -y git
mkdir -p /var/www/
cd /var/www
git clone https://github.com/creativecommons/creativecommons.org
cd creativecommons.org
# Check out the branch being used here if needed
./scripts/bootstrap.sh "${HOSTNAME}"
a2dissite 000-default
apachectl restart

Docker Image
============

docker build -t <name> .
docker run -p 3000:80 <name>
