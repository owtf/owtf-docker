#!/usr/bin/env sh
#
# owtf is an OWASP+PTES-focused try to unite great tools and facilitate pen testing
# Copyright (c) 2014, Abraham Aranguren <name.surname@gmail.com> Twitter: @7a_ http://7-a.org
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# * Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
# * Neither the name of the <organization> nor the
# names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
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

# Restart postgres service. 
/etc/init.d/postgresql restart

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

# Clean db before creating it.
check_owtf_db=$(su - postgres -c "psql -l | grep -w $saved_server_dbname | grep -w $saved_server_user | wc -l")

if [ "$check_owtf_db" != "0" ]; then
    clean_postgres $saved_server_dbname $saved_server_user
fi
init_postgres $saved_server_dbname $saved_server_user $saved_server_pass
