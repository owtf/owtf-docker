FROM kalilinux/kali-linux-docker

MAINTAINER r3naissance

RUN apt-get update && apt-get dist-upgrade -y

# install required packages from Kali repos
COPY packages.sh /
RUN ["sh", "packages.sh"]

# Cleanup
RUN apt-get clean
RUN apt-get -y autoremove

RUN apt-get install -y kali-linux-web

# Fixing Wapiti
RUN apt-get remove -y wapiti
RUN wget https://phoenixnap.dl.sourceforge.net/project/wapiti/wapiti/wapiti-3.0.1/wapiti3-3.0.1.tar.gz && tar -xf wapiti3-3.0.1.tar.gz
RUN cd wapiti3-3.0.1 && python3 setup.py install
RUN wget -P /root/config http://cirt.net/nikto/UPDATES/2.1.5/db_tests && mv /root/config/db_tests /root/config/nikto_db

# Fixing Arachni
RUN rm -rf /usr/share/arachni && wget http://downloads.arachni-scanner.com/nightlies/arachni-2.0dev-1.0dev-linux-x86_64.tar.gz
RUN tar -xf arachni-2.0dev-1.0dev-linux-x86_64.tar.gz && mv arachni-2.0dev-1.0dev /usr/share/arachni

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
