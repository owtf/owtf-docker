FROM kalilinux/kali-linux-docker

MAINTAINER @viyatb viyat.bhalodia@owasp.org, @alexandrasandulescu alecsandra.sandulescu@gmail.com

# Kali signatures preventive update
RUN apt-get update && apt-get dist-upgrade -y && apt-get install -y gnupg
RUN wget -q -O - archive.kali.org/archive-key.asc | apt-key add

# install required packages from Kali repos
COPY packages.sh /
RUN ["sh", "packages.sh"]

# Cleanup
RUN apt-get clean
RUN apt-get -y autoremove

# dowload optional packages archives
COPY optional_tools.sh /usr/bin/
RUN chmod +x /usr/bin/optional_tools.sh

RUN /bin/bash /usr/bin/optional_tools.sh

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
