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
COPY modified/install.py owtf/install/install.py
RUN ["python", "owtf/install/install.py"]
###################
COPY modified/db_setup.sh owtf/scripts/db_setup.sh
COPY modified/owtfdbinstall.sh owtf/scripts/
RUN chmod +x owtf/scripts/owtfdbinstall.sh
###################
COPY modified/dbmodify.py owtf/scripts/
###################
COPY modified/interface_server.py owtf/framework/interface/
RUN ["mv", "-f", "owtf/framework/interface/interface_server.py", "owtf/framework/interface/server.py"]

EXPOSE 8009 8008

# cleanup
RUN rm packages.sh owtf.pip

COPY optional_tools.sh /usr/bin/
RUN chmod +x /usr/bin/optional_tools.sh

#set entrypoint
COPY owtf_entry.sh /usr/bin/
RUN chmod +x /usr/bin/owtf_entry.sh

ENV USER root

ENTRYPOINT ["/usr/bin/owtf_entry.sh"]
