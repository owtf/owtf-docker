FROM kalilinux/kali-linux-docker

MAINTAINER @viyatb viyat.bhalodia@owasp.org, @alexandrasandulescu alecsandra.sandulescu@gmail.com

RUN apt-get update --fix-missing && apt-get upgrade -y

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
RUN git clone -b develop https://github.com/owtf/owtf.git
RUN mkdir owtf/tools/restricted

ENV TERM xterm
ENV SHELL /bin/bash

# core installation
RUN python owtf/install/install.py

# expose ports
EXPOSE 8010 8009 8008

#setup postgres
USER postgres
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# setting user to root
ENV USER root
USER root

# Copy postgres_entry to scripts
COPY postgres_entry.sh owtf/scripts

#set entrypoint
COPY owtf_entry.sh /usr/bin/
RUN chmod +x /usr/bin/owtf_entry.sh

ENTRYPOINT ["/usr/bin/owtf_entry.sh"]
