FROM frenchbeard/centos-dev:latest

MAINTAINER frenchbeard <frenchBeardSec@gmail.com>

ADD pg_setup.sh    /pg_setup
ADD pg_run.sh      /pg_run

RUN rpm -Uvh http://yum.postgresql.org/9.4/redhat/rhel-7-x86_64/pgdg-centos94-9.4-1.noarch.rpm \
&& yum update -y \
&& yum install -y postgresql94-server postgresql94-contrib pwgen \
&& rm -rf /var/lib/pgsql \
&& chmod 755 /pg_run /pg_setup \
&& /pg_setup

EXPOSE 5432

VOLUME ["/run/pgsql"]
VOLUME ["/var/lib/pgsql"]

CMD ["/pg_run"]
