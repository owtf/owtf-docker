FROM kalilinux/kali-linux-docker

MAINTAINER ahiknsr

RUN apt-get update && apt-get upgrade -y

#Kali SSL lib-fix
ENV PYCURL_SSL_LIBRARY gnutls

COPY packages.sh /
COPY owtf.pip /
COPY optional_tools.sh /

RUN ["sh", "packages.sh"]

#upgrade pip before upgrading other packages using pip
RUN pip install --upgrade pip
RUN rm -rf /usr/lib/python2.7/dist-packages/setuptools.egg-info

RUN ["pip", "install", "-r", "owtf.pip"]

RUN pip install --upgrade six simplejson pyOpenSSL==0.12
RUN pip install --upgrade -r owtf.pip


#download OWTF
RUN wget https://github.com/owtf/owtf/archive/v1.0.1.tar.gz
RUN tar xvf v1.0.1.tar.gz
RUN mv owtf-1.0.1 owtf/
RUN mkdir owtf/tools/restricted

###################
RUN wget https://gist.githubusercontent.com/Ahiknsr/797cb9ac52a249ad0d59/raw/e51f5a2fc8019ed02e3b001c5ed9ad901987f2a3/owtfdocker -O owtf/install/install.py
RUN ["python", "owtf/install/install.py"]
###################
RUN wget https://gist.githubusercontent.com/Ahiknsr/957d204e6d965db08b06/raw/a4ab25a9ab56da7536e02d9c8ffd9de8931c01ad/owtfdbinstall -O owtf/scripts/owtfinstall.sh
RUN ["/bin/bash", "owtf/scripts/owtfinstall.sh"]
###################
RUN wget https://gist.githubusercontent.com/Ahiknsr/31ce4c694767d59ef35b/raw/8bce404a8653abe48eb3db09d29061f04c1c90e1/dbmodify -O dbmodify.py
RUN ["python", "dbmodify.py"]
###################
RUN wget https://gist.githubusercontent.com/Ahiknsr/e600b0e4e51865a6dfa0/raw/094d296e1cd5c0947064606b1cadffab7aa3c3f7/modifiedserver.py -O owtf/framework/interface/server.py
###################

#optional tools for OWTF
RUN ["/bin/sh", "optional_tools.sh"]

#Enable and start postgresql
RUN systemctl enable postgresql.service && systemctl start postgresql.service

#cert-fix
RUN mkdir /.owtf ; cp -r /root/.owtf/* /.owtf/

EXPOSE ["8009", "8008"]

# cleanup
RUN rm packages.sh owtf.pip v1.0.1.tar.gz

CMD ["python", "owtf/owtf.py"]
