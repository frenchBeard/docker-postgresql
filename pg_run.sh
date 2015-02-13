#! /usr/bin/env bash

# default values for container setup
PG_VERSION="9.4"
PG_HOME="/var/lib/pgsql"
PG_BINDIR="/usr/pgsql-${PG_VERSION}/bin"
PG_DATADIR="${PG_HOME}/main"
PG_RUNDIR="/run/pgsql"

cd ${PG_HOME}

# initialize PostgreSQL data directory
if [ ! -d ${PG_DATADIR} ]; then

    if [ ! -f "${PG_HOME}/pwfile" ]; then
        PG_PASSWORD=$(pwgen -c -n -1 14)
        echo "${PG_PASSWORD}" > ${PG_HOME}/pwfile
    fi

    echo "Initializing database..."
    su postgres -c "${PG_BINDIR}/initdb \
        --pgdata=${PG_DATADIR} --pwfile=${PG_HOME}/pwfile \
        --username=postgres --encoding=unicode --auth=trust"
fi

if [ -f ${PG_HOME}/pwfile ]; then
    PG_PASSWORD=$(cat ${PG_HOME}/pwfile)
    echo "|------------------------------------------------------------------|"
    echo "| PostgreSQL User: postgres, Password: ${PG_PASSWORD}              |"
    echo "|                                                                  |"
    echo "| To remove the PostgreSQL login credentials from the logs, please |"
    echo "| make a note of password and then delete the file pwfile          |"
    echo "| from the data store.                                             |"
    echo "|------------------------------------------------------------------|"
fi

if [ -n "${DB_USER}" ]; then
    if [ -z "${DB_PASS}" ]; then
        echo ""
        echo "WARNING: "
        echo "  Please specify a password for \"${DB_USER}\". Skipping user creation..."
        echo ""
        DB_USER=
    else
        echo "Creating user \"${DB_USER}\"..."
        echo "CREATE ROLE ${DB_USER} with LOGIN CREATEDB PASSWORD '${DB_PASS}';" |
        su postgres -c "${PG_BINDIR}/postgres --single \
            -D ${PG_DATADIR} -c config_file=${PG_DATADIR}/postgresql.conf"
    fi
fi

if [ -n "${DB_NAME}" ]; then
    for db in $(awk -F',' '{for (i = 1 ; i <= NF ; i++) print $i}' <<< "${DB_NAME}"); do
        echo "Creating database \"${db}\"..."
        echo "CREATE DATABASE ${db};" | \
            su postgres -c "${PG_BINDIR}/postgres --single \
            -D ${PG_DATADIR} -c config_file=${PG_DATADIR}/postgresql.conf >/dev/null"

        if [ -n "${DB_USER}" ]; then
            echo "Granting access to database \"${db}\" for user \"${DB_USER}\"..."
            echo "GRANT ALL PRIVILEGES ON DATABASE ${db} to ${DB_USER};" |
            su postgres -c "${PG_BINDIR}/postgres --single \
                -D ${PG_DATADIR} -c config_file=${PG_DATADIR}/postgresql.conf"
        fi
    done
fi

# listen on all interfaces
cat >> ${PG_DATADIR}/postgresql.conf <<EOF
listen_addresses = '*'
EOF

# allow remote connections to postgresql database
cat >> ${PG_DATADIR}/pg_hba.conf <<EOF
host all all 0.0.0.0/0 md5
EOF

echo "Starting PostgreSQL server..."
exec su postgres -c "${PG_BINDIR}/postgres \
    -D ${PG_DATADIR} -c config_file=${PG_DATADIR}/postgresql.conf"
