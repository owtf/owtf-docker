FROM debian:jessie

MAINTAINER ahiknsr

#Adding kali sources
RUN wget https://gist.githubusercontent.com/Ahiknsr/701f2896b642930ce2e8/raw/868e1e465e3f3498420db89e6eca1679537e2f57/dockerinitialsetup -O aptsetup.sh 
RUN chmod +x aptsetup.sh; bash aptsetup.sh
#apt-get prompt will not prompt for yes or no and takes yes as default choice
RUN wget https://gist.githubusercontent.com/Ahiknsr/21b8f32d80b423aa31bd/raw/e1e5974f6baf941a8011481fee6d516eca69d54e/aptalwaysyes -O aptalwaysyes.sh
RUN chmod +x aptalwaysyes.sh; bash aptalwaysyes.sh
#install few tools in repo which are nessacary for owtf 
RUN wget https://gist.githubusercontent.com/Ahiknsr/c76417641a22c40c29ce/raw/5209cfa5f13da315a2f272e6fb5a79d492a2805d/nativetools -O nativetools.sh
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
RUN wget https://gist.githubusercontent.com/Ahiknsr/957d204e6d965db08b06/raw/78ca180f4ad62b5da69847adbc7533508eb45bc5/owtfdbinstall -O owtf/scripts/owtfinstall.sh 
RUN chmod +x owtf/scripts/owtfinstall.sh 
RUN bash owtf/scripts/owtfinstall.sh
RUN wget https://gist.githubusercontent.com/Ahiknsr/31ce4c694767d59ef35b/raw/61d1a0edcfc932b42e6306e23788e2b9b8ea25c2/dbmodify -O dbmodify.py
RUN python dbmodify.py


RUN echo "service postgresql start" >> ~/.bashrc
RUN echo "Installation of owtf is complete :) "


