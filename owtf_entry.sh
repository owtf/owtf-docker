#! /bin/bash
# @param : --help (-h) echos the usage of running the dockerfile
# @param : --update (-u) installs the optional dependencies
# @param : --exposed (-e) access to web ui

function parse_arg {
  if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    echo "Usage : $0 [OPTIONS]" >&2
    echo -e "-h, --help\n\tDisplay help and exit" >&2
    echo -e "-u, --update\n\tInstall optional dependencies" >&2
    echo -e "-e, --exposed\n\tAllow access to the web ui. Recommended when a virtual host is used" >&2
    return
  fi

  if [[ "$1" == "--update" ]] || [[ "$1" == "-u" ]]; then
    echo "[*] Installing optional dependencies ..." >&2
    /bin/bash /usr/bin/optional_tools.sh
    echo "[*] OWTF optional dependencies were successfully installed" >&2
  fi

  if [[ "$1" == "--exposed" ]] || [[ "$1" == "-e" ]]; then
    echo "[*] Make sure you run this image with the proper parameters" >&2
    echo "[*] #docker run -it -p 8008:8008 -p 8009:8009 -p 8010:8010 --privileged <image_name>" >&2
    patch owtf/framework/config/framework_config.cfg -i owtf/framework_config.cfg.patch
    patch owtf/profiles/general/default.cfg -i owtf/default.cfg.patch
  fi

  rm -f owtf/default.cfg.patch
  rm -f owtf/framework_config.cfg.patch
}

# Start postgres server and configure db.
sh owtf/scripts/postgres_entry.sh

if [ $# -gt 0 ]; then
  for arg in "$@"
  do
    parse_arg $arg
    if [[ "$arg" == "--help" ]] || [[ "$arg" == "-h" ]]; then
        exit 0
    fi
  done
fi

# Run owtf.
cd owtf
./owtf.py
