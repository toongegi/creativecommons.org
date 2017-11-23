FROM "debian:jessie"

WORKDIR /

ADD . /var/www/creativecommons.org/

################################################################################
# TEMPORARY HACK:
# https://superuser.com/questions/1270116/mediagoblin-cant-create-docker-container-invalid-environment-marker
# Because (we don't use astroid but this explains the issue):
# https://github.com/PyCQA/astroid/issues/358
RUN apt update
RUN apt install -y python-sphinx
################################################################################

RUN /var/www/creativecommons.org/scripts/bootstrap.sh 0.0.0.0

EXPOSE 80

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]