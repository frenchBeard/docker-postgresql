FROM frenchbeard/centos-dev:latest

MAINTAINER frenchbeard <frenchBeardSec@gmail.com>

RUN yum install -y postgresql-server

ADD pg_setup.sh    /pg_setup
ADD pg_run.sh      /pg_run
RUN chmod 755   /pg_run /pg_setup
RUN /pg_setup

VOLUME ["/run/postgresql"]
VOLUME ["/var/lib/postgresql"]

EXPOSE 5432

CMD ["pg_run"]
