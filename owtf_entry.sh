#! /bin/bash
# @param : --help (-h) echos the usage of running the dockerfile
# @param : --update (-u) installs the optional dependencies

function parse_arg {
  if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    echo "Usage : $0 [OPTIONS]" >&2
    echo -e "-h, --help\n\tDisplay help and exit" >&2
    echo -e "-u, --update\n\tInstall optional dependencies" >&2
    return
  fi

  if [[ "$1" == "--update" ]] || [[ "$1" == "-u" ]]; then
    echo "Installing optional dependencies ..." >&2
    /bin/bash /usr/bin/optional_tools.sh
    echo "OWTF optional dependencies were successfully installed" >&2
  fi

}
if [ $# -gt 0 ]; then
  for arg in "$@"
  do
    parse_arg $arg
    if [[ "$arg" == "--help" ]] || [[ "$arg" == "-h" ]]; then
        exit 0
    fi
  done
fi

python owtf/scripts/dbmodify.py
/bin/bash owtf/scripts/owtfdbinstall.sh
python owtf/owtf.py
