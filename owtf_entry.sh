#! /bin/bash
# @param : --help (-h) echos the usage of running the dockerfile
# @param : --update (-u) installs the optional dependencies
# @param : --exposed (-e) access to web ui

function parse_arg {
  if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    echo "Usage : $0 [OPTIONS]" >&2
    echo -e "-h, --help\n\tDisplay help and exit" >&2
    echo -e "-u, --update\n\tInstall optional dependencies" >&2
    return
  fi

  if [[ "$1" == "--update" ]] || [[ "$1" == "-u" ]]; then
    echo "[*] Installing optional dependencies ..." >&2
    /bin/bash /usr/bin/optional_tools.sh
    echo "[*] OWTF optional dependencies were successfully installed" >&2
  fi
}

# Patch server address so that they are exposed to the host
sed -i 's@INBOUND_PROXY_IP: 127.0.0.1@INBOUND_PROXY_IP: 0.0.0.0@' ${HOME}/.owtf/conf/general.cfg
sed -i 's@SERVER_ADDR: 127.0.0.1@SERVER_ADDR: 0.0.0.0@' ${HOME}/.owtf/conf/framework.cfg

# Start postgres server and configure db.
sh /owtf/postgres_entry.sh

if [ $# -gt 0 ]; then
  for arg in "$@"
  do
    parse_arg $arg
    if [[ "$arg" == "--help" ]] || [[ "$arg" == "-h" ]]; then
        exit 0
    fi
  done
fi

# Run owtf
python3 -m owtf
