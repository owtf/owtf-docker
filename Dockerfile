FROM debian:jessie

RUN apt-get update && apt-get upgrade -y --force-yes
MAINTAINER ahiknsr
#Adding kali sources
RUN apt-cache search wget
RUN apt-get install wget -y --force-yes
RUN wget --no-check-certificate https://gist.githubusercontent.com/Ahiknsr/701f2896b642930ce2e8/raw/868e1e465e3f3498420db89e6eca1679537e2f57/dockerinitialsetup -O aptsetup.sh 
RUN chmod +x aptsetup.sh; bash aptsetup.sh
#apt-get prompt will not prompt for yes or no and takes yes as default choice
RUN wget --no-check-certificate https://gist.githubusercontent.com/Ahiknsr/21b8f32d80b423aa31bd/raw/e1e5974f6baf941a8011481fee6d516eca69d54e/aptalwaysyes -O aptalwaysyes.sh
RUN chmod +x aptalwaysyes.sh; bash aptalwaysyes.sh
#install few tools in repo which are nessacary for owtf 
RUN wget --no-check-certificate https://gist.githubusercontent.com/Ahiknsr/c76417641a22c40c29ce/raw/5209cfa5f13da315a2f272e6fb5a79d492a2805d/nativetools -O nativetools.sh
RUN chmod +x nativetools.sh; bash nativetools.sh
RUN rm *.sh
#install necessary python modules 
RUN wget  https://raw.githubusercontent.com/owtf/owtf/master/install/owtf.pip -O owtf.pip
RUN pip install -r owtf.pip 
RUN pip install --upgrade six
RUN pip install simplejson
RUN pip install pyOpenSSL==0.12
RUN pip install --upgrade -r owtf.pip; rm owtf.pip
#download owtf 
RUN wget https://github.com/owtf/owtf/archive/v1.0.1.tar.gz
RUN tar xvf v1.0.1.tar.gz
RUN mv owtf-1.0.1 owtf
RUN mkdir owtf/tools/restricted
RUN rm v1.0.1.tar.gz

RUN wget https://gist.githubusercontent.com/Ahiknsr/797cb9ac52a249ad0d59/raw/e51f5a2fc8019ed02e3b001c5ed9ad901987f2a3/owtfdocker -O owtf/install/install.py
RUN python owtf/install/install.py
RUN wget  https://gist.githubusercontent.com/Ahiknsr/957d204e6d965db08b06/raw/a4ab25a9ab56da7536e02d9c8ffd9de8931c01ad/owtfdbinstall -O owtf/scripts/owtfinstall.sh 
RUN chmod +x owtf/scripts/owtfinstall.sh 
RUN bash owtf/scripts/owtfinstall.sh
RUN wget https://gist.githubusercontent.com/Ahiknsr/31ce4c694767d59ef35b/raw/8bce404a8653abe48eb3db09d29061f04c1c90e1/dbmodify -O dbmodify.py
RUN python dbmodify.py
RUN wget https://gist.githubusercontent.com/Ahiknsr/e600b0e4e51865a6dfa0/raw/094d296e1cd5c0947064606b1cadffab7aa3c3f7/modifiedserver.py -O owtf/framework/interface/server.py

RUN apt-get install  theharvester tlssled nikto dnsrecon nmap whatweb skipfish w3af-console dirbuster wpscan wapiti waffit hydra 
RUN systemctl enable postgresql.service
RUN mkdir /.owtf ; cp -r /root/.owtf/* /.owtf/
RUN echo "service postgresql start" >> ~/.bashrc
RUN echo "Installation of owtf is complete :) "


