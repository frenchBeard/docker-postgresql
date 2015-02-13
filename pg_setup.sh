#! /usr/bin/env bash

# exit if any command fails
set -e

# default values for container setup
PG_HOME="/var/lib/postgresql"
PG_CONFDIR="/etc/postgresql/main"
PG_BINDIR="/usr/lib/postgresql/bin"
PG_DATADIR="${PG_HOME}/main"
PG_RUNDIR="/run/postgresql"

# fix ownership / permissions of ${PG_HOME}
mkdir -p -m 0700 ${PG_HOME}
chown -R postgres:postgres ${PG_HOME}

# fix ownership / permissions of ${PG_HOME}
mkdir -p -m 0755 ${PG_RUNDIR} ${PG_RUNDIR}/main.pg_stat_tmp
chown -R postgres:postgres ${PG_RUNDIR}
chmod g+s ${PG_RUNDIR}

# listen on all interfaces
cat >> ${PG_CONFDIR}/postgresql.conf <<EOF
listen_addresses = '*'
EOF

# allow remote connections to postgresql database
cat >> ${PG_CONFDIR}/pg_hba.conf <<EOF
host all all 0.0.0.0/0 md5
EOF
i
# setting up the database
cd ${PG_HOME}

# initialize PostgreSQL data directory
if [ ! -d ${PG_DATADIR} ]; then
    # check if we need to perform data migration
    if [ ! -f "${PG_HOME}/pwfile" ]; then
        PG_PASSWORD=$(pwgen -c -n -1 14)
        echo "${PG_PASSWORD}" > ${PG_HOME}/pwfile
    fi
    echo "Initializing database..."
    sudo -u postgres -H "${PG_BINDIR}/initdb" \
        --pgdata="${PG_DATADIR}" --pwfile=${PG_HOME}/pwfile \
        --username=postgres --encoding=unicode --auth=trust >/dev/null
fi

