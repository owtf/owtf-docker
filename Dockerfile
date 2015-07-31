FROM kalilinux/kali-linux-docker

MAINTAINER delta24

RUN apt-get update && apt-get upgrade -y

#Kali SSL lib-fix
ENV PYCURL_SSL_LIBRARY openssl

COPY packages.sh /
RUN ["sh", "packages.sh"]

COPY owtf.pip /
RUN ["pip", "install", "--upgrade", "pip"]
RUN ["pip", "install", "--upgrade", "-r", "owtf.pip"]

#download latest OWTF
RUN git clone -b develop https://github.com/owtf/owtf.git
RUN mkdir owtf/tools/restricted

###################
RUN python owtf/install/install.py --no-user-input --core-only
###################
COPY modified/db_setup.sh owtf/scripts/db_setup.sh
COPY modified/owtfdbinstall.sh owtf/scripts/
RUN chmod +x owtf/scripts/owtfdbinstall.sh
###################
COPY modified/dbmodify.py owtf/scripts/
###################

EXPOSE 8010 8009 8008

# cleanup
RUN rm packages.sh owtf.pip

COPY optional_tools.sh /usr/bin/
RUN chmod +x /usr/bin/optional_tools.sh

#setup postgres
USER postgres
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

ENV USER root
USER root

#set entrypoint
COPY owtf_entry.sh /usr/bin/
RUN chmod +x /usr/bin/owtf_entry.sh

ENTRYPOINT ["/usr/bin/owtf_entry.sh"]
