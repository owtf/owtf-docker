PACKAGES="theharvester \
          tlssled \
          nikto \
          dnsrecon \
          nmap \
          whatweb \
          skipfish \
          dirbuster \
          metasploit-framework \
          wpscan \
          wapiti \
          hydra \
          metagoofil \
          o-saft"

if [ "$1" = "--download-only" ]; then
  install_args="-d -y"
else
  install_args="-y"
fi

for package in $PACKAGES; do
  if ! apt-get install $install_args "$package"; then
    echo "[!] Skipping unavailable optional package: $package"
  fi
done
