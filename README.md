## OWTF - Offensive Web Testing Framework
Official Docker image for [OWASP OWTF](http://owtf.org).

There are two different Docker images for w3af: `stable` and `unstable`. The
`stable` image is built from the `master` branch in the project repositories while
`unstable` is built from `develop`.

## Usage:

*  Install **Docker**.(specific instructions can be found [here](https://docs.docker.com/installation/)).

*  Then run these commands, please notice that the first time these commands are run the script will download docker images from the registry,
   which might take a while depending on your internet connection.

   ```
   git clone https://github.com/owtf/owtfdocker64.git

*  Run `docker build -t <yourpreferredname> <path to Dockerfile>`.

*  You can launch your **OWTF** container by running `docker -itd -p 8009:8009 <image name>`.
   - `-d` launches the container as a *daemon*.
   - `-p 8009:8009` maps the port 8009 of the host machine to the port 8009 of the container. (syntax: `<host port>:<container port>`)
   - Get the image name by running `docker images`.

*  To get a shell inside a running container (as *daemon*), run `docker exec -it <containerid> /bin/bash`. Get the container id by running `docker ps -a`.

*  Inside the container, run `python owtf/owtf.py` to start **OWTF**. Once the web interface has been initialised successfully, point your browser to `<hostip>:8009`.
