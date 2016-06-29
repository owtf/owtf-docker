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

config_file="$RootDir/framework/config/framework_config.cfg"
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

# Restart postgres service.
systemctl_bin=$(which systemctl | wc -l 2> /dev/null)
if [ "$systemctl_bin" = "1" ]; then
  systemctl restart postgresql
else
  START_CMD="/usr/lib/postgresql/${postgres_version}/bin/pg_ctl -w \
    -D $PGDATA \
    -o \"-c config_file=/etc/postgresql/${postgres_version}/main/postgresql.conf\" \
    restart"
  su postgres -c "$START_CMD" >> $PGLOG 2> $PGLOG
fi

# Refresh postgres settings
postgres_server_ip=$(get_postgres_server_ip)
postgres_server_port=$(get_postgres_server_port)

if [ "$postgres_server_ip" != "$saved_server_ip" ] || [ "$postgres_server_port" != "$saved_server_port" ]; then
    echo "[+] Postgres running on $postgres_server_ip:$postgres_server_port"
    echo "[+] OWTF db config points towards $saved_server_ip:$saved_server_port"

    if [ "$choice" != "n" ]; then
        if [ "$saved_server_ip" == "" ]; then
            sed -i "s/DATABASE_IP*:/& $postgres_server_ip/" $db_config_file
        else
            sed -i "/DATABASE_IP/s/$saved_server_ip/$postgres_server_ip/" $db_config_file
        fi
        if [ "$saved_server_port" == "" ]; then
            sed -i "s/DATABASE_PORT*:/& $postgres_server_port/" $db_config_file
        else
            sed -i "/DATABASE_PORT/s/$saved_server_port/$postgres_server_port/" $db_config_file
        fi
        echo "[+] New database configuration saved"
    fi
fi

postgresql_fix() {
  # remove SSL=true from the postgresql main config
  postgres_version="$(psql --version 2>&1 | tail -1 | awk '{print $3}' | sed 's/\./ /g' | awk '{print $1 "." $2}')"
  postgres_conf="$(echo 'SHOW config_file;' | sudo -u postgres psql | grep 'postgres')"
  echo "Having SSL=true in postgres config causes many errors (psycopg2 problem)"
  # patched for docker installation
  remove_ssl="y"  # tolower
  case $remove_ssl in
    [yY][eE][sS]|[yY])
      sed -i -e '/ssl =/ s/= .*/= false/' $postgres_conf

      echo "Restarting the postgresql service"
      # get the return values of which commands to determine the service controller
      which service  >> /dev/null 2>&1
      service_bin=$?
      which systemctl  >> /dev/null 2>&1
      systemctl_bin=$?
      if [ "$service_bin" != "1" ]; then
        service postgresql restart
        service postgresql status | grep -q '^Running clusters: ..*$'
        status_exitcode="$?"
      elif [ "$systemctl_bin" != "1" ]; then
        systemctl restart postgresql
        systemctl status postgresql | grep -q "active"
        status_exitcode="$?"
      else
        echo "[+] It seems postgres server is not running or responding, please start/restart it manually!"
        exit 1
      fi
      ;;
    *)
      # do nothing
      ;;
  esac
}

# Clean db before creating it.
check_owtf_db=$(su - postgres -c "psql -l | grep -w $saved_server_dbname | grep -w $saved_server_user | wc -l")

if [ "$check_owtf_db" != "0" ]; then
    clean_postgres $saved_server_dbname $saved_server_user
fi

# Fix postgresql config
postgresql_fix

init_postgres $saved_server_dbname $saved_server_user $saved_server_pass
