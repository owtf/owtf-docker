FROM kalilinux/kali-linux-docker

MAINTAINER r3naissance

RUN apt-get update && apt-get dist-upgrade -y

# install required packages from Kali repos
COPY packages.sh /
RUN ["sh", "packages.sh"]

# Cleanup
RUN apt-get clean
RUN apt-get -y autoremove

# Install some Kali components
# See https://www.kali.org/news/kali-linux-metapackages/ for details
RUN apt-get install -y kali-linux-top10 kali-linux-web

#Kali SSL lib-fix
ENV PYCURL_SSL_LIBRARY openssl

#download latest OWTF
RUN git clone -b master https://github.com/owtf/owtf.git
RUN mkdir -p /owtf/data/tools/restricted

ENV TERM xterm
ENV SHELL /bin/bash

WORKDIR /owtf

# core installation
RUN python setup.py develop

# expose ports
EXPOSE 8010 8009 8008

#setup postgres
USER postgres
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# setting user to root
ENV USER root
USER root

# Copy postgres_entry to scripts
COPY postgres_entry.sh /owtf/

#set entrypoint
COPY owtf_entry.sh /usr/bin/
RUN chmod +x /usr/bin/owtf_entry.sh

ENTRYPOINT ["/usr/bin/owtf_entry.sh"]
