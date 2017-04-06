# This script runs postgres server in very stupid ways, this script is tested
# extensively on Kali

get_config_value(){
    parameter=$1
    file=$2
    echo "$(grep -i $parameter $file | sed  "s|$parameter: ||g;s|~|$HOME|g")"
}

get_postgres_server_ip() {
    echo "$(sudo netstat -lptn | grep "^tcp " | grep postgres | sed 's/\s\+/ /g' | cut -d ' ' -f4 | cut -d ':' -f1)"
}

get_postgres_server_port() {
    echo "$(sudo netstat -lptn | grep "^tcp " | grep postgres | sed 's/\s\+/ /g' | cut -d ' ' -f4 | cut -d ':' -f2)"
}

# Bail out if not root privileges
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

init_postgres() {
    db_name=$1
    db_user=$2
    db_pass=$3
    su postgres -c "psql -c \"CREATE USER $db_user WITH PASSWORD '$db_pass'\""
    su postgres -c "psql -c \"CREATE DATABASE $db_name WITH OWNER $db_user ENCODING 'utf-8' TEMPLATE template0;\""
}

clean_postgres() {
    db_name=$1
    db_user=$2
    su postgres -c "psql -c \"DROP DATABASE $db_name\""
    su postgres -c "psql -c \"DROP USER $db_user\""
}

FILE_PATH=$(readlink -f "$0")
SCRIPTS_DIR=$(dirname "$FILE_PATH")
RootDir=${1:-$(dirname "$SCRIPTS_DIR")}

config_file="/root/.owtf/configuration/framework_config.cfg"
db_config_file="$(get_config_value DATABASE_SETTINGS_FILE $config_file)"

# Saved postgres settings
saved_server_ip="$(get_config_value DATABASE_IP $db_config_file)"
saved_server_port="$(get_config_value DATABASE_PORT $db_config_file)"
saved_server_dbname="$(get_config_value DATABASE_NAME $db_config_file)"
saved_server_user="$(get_config_value DATABASE_USER $db_config_file)"
saved_server_pass="$(get_config_value DATABASE_PASS $db_config_file)"

postgres_version="$(psql --version 2>&1 | tail -1 | awk '{print $3}' | sed 's/\./ /g' | awk '{print $1 "." $2}')"

# Postgres setup.
PGDATA=/var/lib/postgresql/${postgres_version}/data
PGLOG=$PGDATA/serverlog

mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql
mkdir -p $PGDATA && chown -R postgres $PGDATA

postgresql_start() {
  echo "Starting the postgresql service"
  # get the return values of which commands to determine the service controller
  which service  >> /dev/null 2>&1
  service_bin=$?
  which systemctl  >> /dev/null 2>&1
  systemctl_bin=$?
  if [ "$service_bin" != "1" ]; then
    service postgresql start
    service postgresql status | grep -q '^Running clusters: ..*$'
    status_exitcode="$?"
  elif [ "$systemctl_bin" != "1" ]; then
    systemctl start postgresql
    systemctl status postgresql | grep -q "active"
    status_exitcode="$?"
  elif [ "$systemctl_bin" != "0" ] && [ "$service_bin" != "0" ]; then
      echo "[+] Using pg_ctlcluster to start the server."
      sudo pg_ctlcluster ${postgres_version} main start
  else
      echo "[+] We couldn't determine how to start the postgres server, please start it and rerun this script"
      exit 1
  fi
}

postgresql_start

# Clean db before creating it.
check_owtf_db=$(su - postgres -c "psql -l | grep -w $saved_server_dbname | grep -w $saved_server_user | wc -l")

if [ "$check_owtf_db" != "0" ]; then
    clean_postgres $saved_server_dbname $saved_server_user
fi


init_postgres $saved_server_dbname $saved_server_user $saved_server_pass
