## OWTF - Offensive Web Testing Framework

Official Docker image for [OWASP OWTF](http://owtf.org).

This image builds the OWTF `develop` branch by default. You can override the
`OWTF_VERSION` build argument to pin the image to a different tag or branch if
needed.

### Building the image:

*  Install **Docker**.(specific instructions can be found [here](https://docs.docker.com/installation/)).

*  Then run these commands, please notice that the first time these commands are run the script will download docker images from the registry,
   which might take a while depending on your internet connection.

   ```
   git clone https://github.com/owtf/owtf-docker.git

   ```

*  Run `docker build -t <yourpreferredname> <path to Dockerfile>`.

### Usage

*  You can launch your **OWTF** container by running `$ docker run -it -p 8008:8008 -p 8009:8009 -p 8010:8010 <image name> /bin/bash`
   - `-p` flags map the host port to the container port
   - Get the image name by running `docker images`.

* To use the OWTF mitm proxy, set the proxy settings to `localhost:8008`.

* Point your browser to `<hostip>:8009`.

### Persistent updated image

* You can save the updated image by following these steps:
1. Run the OWTF image as usual.
2. Commit the running image into a new one. You can find the
   container_id by running `# docker ps`
`$ docker commit <container_id> <extended image name>`
3. Run the extended image
