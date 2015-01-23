Instructions to build your OWTF Docker image:
===

1. Install **Docker**.(specific instructions can be found [here](https://docs.docker.com/installation/)).

2. Run `docker build -t <yourpreferredname> <path to Dockerfile>`.

3. You can launch your **OWTF** container by running `docker -itd -p 8009:8009 <image name>`.
   - `-d` launches the container as a *daemon*.
   - `-p 8009:8009` maps the port 8009 of the host machine to the port 8009 of the container. (syntax: `<host port>:<container port>`)
   - Get the image name by running `docker images`.

4. To get a shell inside a running container (as *daemon*), run `docker -it exec /bin/bash <containerid>`. Get the container id by running `docker ps -a`.

5. Inside the container, run `python owtf/owtf.py` to start **OWTF**. Once the web interface has been initialised successfully, point your browser to `<hostip>:8009`.
