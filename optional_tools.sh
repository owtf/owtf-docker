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
          waffit \
          hydra \
          metagoofil \
          o-saft"

if [ "$1" = "--download-only" ]; then
  apt-get install -d -y $PACKAGES
else
  apt-get install -y $PACKAGES
fi
