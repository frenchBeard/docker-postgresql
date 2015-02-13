#! /usr/bin/env bash

# exit if any command fails
set -e

# default values for container setup
PG_VERSION="9.4"
PG_HOME="/var/lib/pgsql"
PG_BINDIR="/usr/pgsql-${PG_VERSION}/bin"
PG_DATADIR="${PG_HOME}/main"
PG_RUNDIR="/run/pgsql"

# fix ownership / permissions of ${PG_HOME}
mkdir -p -m 0700 ${PG_HOME}
chown -R postgres:postgres ${PG_HOME}

# fix ownership / permissions of ${PG_HOME}
mkdir -p -m 0755 ${PG_RUNDIR} ${PG_RUNDIR}/main.pg_stat_tmp
chown -R postgres:postgres ${PG_RUNDIR}
chmod g+s ${PG_RUNDIR}

