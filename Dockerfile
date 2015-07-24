FROM kalilinux/kali-linux-docker

MAINTAINER delta24

RUN apt-get update && apt-get upgrade -y

#Kali SSL lib-fix
ENV PYCURL_SSL_LIBRARY gnutls

COPY packages.sh /
COPY owtf.pip /
COPY optional_tools.sh /
COPY pip-fixes.sh /

RUN ["sh", "packages.sh"]
RUN ["pip", "install", "--upgrade", "pip"]
RUN ["pip", "install", "--upgrade", "-r", "owtf.pip"]

#download latest OWTF
RUN git clone -b develop https://github.com/owtf/owtf.git
RUN mkdir owtf/tools/restricted

###################
COPY modified/install.py -f owtf/install/install.py
RUN ["python", "owtf/install/install.py"]
###################
COPY modified/owtfdbinstall.sh -f owtf/scripts/
RUN ["/bin/bash", "owtf/scripts/owtfdbinstall.sh"]
###################
COPY modified/dbmodify.py owtf/scripts/
RUN ["python", "owtf/scripts/dbmodify.py"]
###################
COPY modified/interface_server.py owtf/framework/interface/
RUN ["mv", "-f", "interface_server.py", "server.py"]

#optional tools for OWTF
RUN ["/bin/sh", "optional_tools.sh"]

#Enable and start postgresql
RUN systemctl enable postgresql.service && systemctl start postgresql.service

#cert-fix
RUN mkdir /.owtf ; cp -r /root/.owtf/* /.owtf/

EXPOSE ["8009", "8008"]

# cleanup
RUN rm packages.sh owtf.pip
CMD ["python", "owtf/owtf.py"]
