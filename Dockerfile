FROM ubuntu:14.04

MAINTAINER Rob Myers <rob@robmyers.org>

# We specify a host name for the template used to create the virtual host
# Add an entry to /etc/hosts to point this to the container's IP
ENV WWWNAME creativecommons.docker
ENV DBNAME wordpress
ENV DBUSER dbuser
ENV DBPASS ""

# So we can install mysql-server with no root password without prompting
ENV DEBIAN_FRONTEND noninteractive

# Allow services to be restarted
RUN perl -i -p -e "s/exit 101/exit 0/" /usr/sbin/policy-rc.d

# Copy in to /var/www so it's somewhere a) findable and b) web accessible
ADD . /var/www/creativecommons.org/

WORKDIR /var/www/creativecommons.org/python_env/bin

# Remove any virtualenv setup (files and symlinks) copied from the environment
# This cleans up from if we ran bootstrap_checkout.sh before
RUN find ! -name ccengine.fcgi.in ! -type d -exec rm -f {} +

WORKDIR /var/www/creativecommons.org

RUN scripts/bootstrap_server_ubuntu.sh \
    "$WWWNAME" "$DBNAME" "$DBUSER" "$DBPASS"

RUN scripts/bootstrap_checkout.sh \
    "$WWWNAME" "$DBNAME" "$DBUSER" "$DBPASS"

# Clear this, as setting DEBIAN_FRONTEND is so bad it's in the Docker FAQ
ENV DEBIAN_FRONTEND ""

EXPOSE 80

# Do more than one thing in the container. This is just for testing
CMD /etc/init.d/mysql start && /usr/sbin/apache2ctl -D FOREGROUND

# Now import or create a database, then commit
