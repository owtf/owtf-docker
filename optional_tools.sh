PACKAGES="theharvester \
          tlssled \
          nikto \
          dnsrecon \
          nmap \
          whatweb \
          skipfish \
          w3af-console \
          dirbuster \
          metasploit \
          wpscan \
          wapiti \
          waffit \
          hydra"

if [ "$1" = "--download-only" ]; then
  apt-get install -d -y $PACKAGES
else
  apt-get install -y $PACKAGES
fi
