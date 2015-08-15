## OWTF - Offensive Web Testing Framework

Official Docker image for [OWASP OWTF](http://owtf.org).

### Building the image:

*  Install **Docker**.(specific instructions can be found [here](https://docs.docker.com/installation/)).

*  Then run these commands, please notice that the first time these commands are run the script will download docker images from the registry,
   which might take a while depending on your internet connection.

   ```
   git clone https://github.com/owtf/owtf-docker.git

   ```

*  Run `docker build -t <yourpreferredname> <path to Dockerfile>`.

### Usage

*  You can launch your **OWTF** container by running
    `# docker run -itd --privileged -p 8008:8008 -p 8009:8009 -p 8010:8010 <image name> -e [-u]`
    `# docker run -itd --privileged --net=host <image name> [-u]`
   - `-d` launches the container as a *daemon*.
   - `-p` flags map the host port to the container port
   - `-e` allow access to web ui. Recommended when a virtual host is
     used
   - `-u` install optional dependencies
   - Get the image name by running `docker images`.

* To use the OWTF mitm proxy, set the proxy settings to `localhost:8008`.

* Point your browser to `<hostip>:8009`.

### Persistent updated image

* You can save the updated image by following these steps:
1. run your docker image with the --update option
`# docker run -it --privileged --net=host <image name> --update`

2. commit the running image into a new one. You can find the
   container_id by running `# docker ps`
`# docker commit <container_id> <extended image name>`

3. run the extended image
`# docker run -it --privileged --net=host <extended image name>`
