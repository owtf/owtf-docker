
Instructions to install owtf in docker container .

1)Fisrt install docker , Instructions can be found here(https://docs.docker.com/installation/) 

2)Then install owtf using docker pull  ahiknsr/owtfdocker64

3)After installing run docker run -i -t ahiknsr/owtfdocker64 /bin/bash to get a interactive shell 

4)get the ip of the container using ifconfig

5)Run python owtf/owtf.py , use can now use owtf's web interface on port 8009 on the container 

