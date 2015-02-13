FROM frenchbeard/centos-dev:latest

MAINTAINER frenchbeard <frenchBeardSec@gmail.com>

RUN yum install -y postgresql-server

ADD pg_setup    /pg_setup
ADD pg_run      /pg_run
RUN chmod 755   /pg_setup
RUN chmod 755   /pg_run
RUN /pg_setup

VOLUME ["/run/postgresql"]
VOLUME ["/var/lib/postgresql"]

EXPOSE 5432

CMD ["pg_run"]
