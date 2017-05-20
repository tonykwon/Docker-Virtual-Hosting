# Docker Virtual Hosting #

### What is this repository for? ###

This repository contains configuration files to run [nginx](https://hub.docker.com/_/nginx/) or [apache](https://hub.docker.com/_/httpd/) containers(with MySQL & PHP support) behind [Docker nginx-proxy](https://github.com/jwilder/nginx-proxy) which automates nginx proxy for Docker containers using docker-gen.

### Background ###

I work on many PHP based applications & websites and I needed a way to be able to customize each "container" instead of having to rely on a single server instance that is shared. The setup described here allows me to run virtual hosting that I can individually customize & tweak. The two examples provided under `skeletons` directory should get you started with a fairly common webserver setup and give you the flexibility to tweak to suit your needs. MySQL Server is always needed and hence it is started when the `nginx-proxy` container runs. Database directory is mounted from the Host side so that the **data persists** even after the container shuts down. (see `_common/database`) It is still strongly recommneded to make backups of the directory as well as perform database dumps.

I am using this setup for developing things locally. I do not recommend using this for production at all.

### Prerequisits ###

Note: This guide is based on OS X as the Docker Host.

0. Ensure no other programs are listening on port 80, 443, 3306 on the host machine.
1. Install & run [Docker Community Edition](https://store.docker.com/search?type=edition&offering=community).
2. Modify Host Database by adding some entries to hosts file. `e.g. /etc/hosts`
`127.0.0.1 apache.dev` and `127.0.0.1 nginx.dev`
3. Run this command once: `$ docker network create service-tier;`
4. Clone this repo ***into a centralized location*** to host all our containerized virtual host apps: `e.g. /Users/tonykwon/Sites`

### Giving it a try - just to see what this repository is all about ###

We will first run containers base off of our main compose file so that we have working nginx-proxy and MariaDB. Since we are pulling from official images, no images will be built locally.
```
$ cd /Users/tonykwon/Sites/_common
$ docker-compose up
```

Once the build (pulling of images really) is complete, check the images on a different terminal:
```
$ docker images
REPOSITORY            TAG                 IMAGE ID            CREATED             SIZE
jwilder/nginx-proxy   latest              ca6685ed24ba        8 days ago          188MB
mariadb               latest              f04960029149        8 days ago          395MB
```

Also, check to see what containers are created & running.
```
$ docker ps -a
CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS                                      NAMES
9197af281717        jwilder/nginx-proxy   "/app/docker-entry..."   2 seconds ago       Up 1 second         0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   nginx-proxy
360df1662580        mariadb               "docker-entrypoint..."   2 seconds ago       Up 1 second         0.0.0.0:3306->3306/tcp                     db
```

To stop, press ctrl+c then `$ docker-compose  down`

```
Gracefully stopping... (press Ctrl+C again to force)
Stopping nginx-proxy ... done
Stopping db ... done

$ docker-compose  down
Removing nginx-proxy ... done
Removing db ... done
Network service-tier is external, skipping
```

Double check to ensure no containers are running:
```
$ docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```

### Giving it a try - build & run containers for apache.dev ###

Now, we need the main containers up and running again.

```
$ cd /Users/tonykwon/_common
$ docker-compose up (to run on the foreground)
or
$ docker-compose up -d (to run on the background)
```

Then on a different terminal, run:
```
$ cd /Users/tonykwon/_common/skeletons/apache.dev/
$ docker-compose up (initial build could take a long time)
```

Try visiting `http://apache.dev/` on a browser to ensure the containers are up and running. Also check to see what images are pulled/created:
```
$ docker images
REPOSITORY             TAG                 IMAGE ID            CREATED             SIZE
apachedev_web          latest              b703da15d542        2 minutes ago       97.8MB
apachedev_app          latest              3397e3bf030c        2 minutes ago       149MB
php                    fpm-alpine          56ed8b111665        6 hours ago         68.6MB
httpd                  alpine              a3ef8c72123c        25 hours ago        94.8MB
jwilder/nginx-proxy    latest              ca6685ed24ba        8 days ago          188MB
mariadb                latest              f04960029149        8 days ago          395MB
```

### Giving it a try - build & run containers for nginx.dev ###

```
$ cd /Users/tonykwon/_common/skeletons/nginx.dev/
$ docker-compose up
```

Try visiting `http://nginx.dev/` on a browser to ensure the containers are up and running. Similarly, check to see what images are pulled/created by running `$ docker images` command.

### Typical Workflow ###

We need the nginx-proxy & database containers running while we are working so on the main terminal we run:
```
$ cd /Users/tonykwon/Sites/_common
$ docker-compose up    (to run on the foreground)
or
$ docker-compose up -d (to run on the background)
```

e.g. Your new site you want to work on is `test.dev`

1. Add `127.0.0.1 test.dev` to your hosts file.
2. Create a directory named `test.dev` under `/Users/tonykwon/Sites`.
3. Pick a skeleton from `_common/skeletons` directory then copy the content into `test.dev` directory.
4. Open `docker-compose.yml` file and make necessary adjustments: volumes(document root to match the virtual host name), environment(VIRTUAL_HOST, DOCUMENT_ROOT).
5. Review the content of `__Docker` directory and make necessary adjustments e.g. `php.ini` and `www.conf`
6. Move to the top level directory: `$ cd /Users/tonykwon/Sites/test.dev`
7. build & run: `$ docker-compose up`
8. Once you are done with `test.dev` (ctrl+c to halt) then `$ docker-compose down`

NOTE
+ To reach the database server from the Docker Host, (e.g. using Sequel Pro) use `127.0.0.1`, `Username: root`, `Password: password`
+ To reach the database server from the container, use `db` as hostname

### Overall Directory Structure ###
```
Sites/
    _common
        database                -> mapped to /var/lib/mysql of database container
        certs                   -> ssl certificates
        skeletons               -> 2 example configurations
        vhost.d                 -> mapped to /etc/nginx/vhost.d of the nginx proxy which listens on 80, 443
        docker-compose.yml
```

```
Sites/skeletons
    apache.dev                  -> apache example
        __Docker
            app.dockerfile      -> Dockerfile that builds php-fpm
            web.dockerfile      -> Dockerfile that builds apache
            vhost.conf          -> VirtualHost configuration for apache
            php.ini             -> Custom php.ini configuration
            www.conf            -> Custom php-fpm configuration
        docker-compose.yml
        index.html
        index.php

     nginx.dev                  -> nginx example
        __Docker
            app.dockerfile      -> Dockerfile that builds php-fpm
            web.dockerfile      -> Dockerfile that builds nginx
            vhost.conf          -> Virtualhost configuration for nginx
            php.ini             -> Custom php.ini configuration
            www.conf            -> Custom php-fpm configuration
        docker-compose.yml
        index.html
        index.php

    php.dev                     -> stand-alone PHP example
        __Docker
            app.dockerfile      -> Dockerfile that builds php
            app-zts.dockerfile  -> Dockerfile that build php w/ ZTS support
            php.ini             -> Custom php.ini configuration
        docker-compose.yml
        index.php
```

### SSL Support ###

Say you want some SSL support for VIRTUAL_HOST `ssl.dev` per se using self-signed ssl certificate. The default setup redirects all non-ssl traffic to ssl then assumes the SSL backend is non-ssl (which works perfect in our setup as we do not need to touch the existing vhost.conf)

1. Move to the common certs directory. `$ cd /Users/tonykwon/Sites/_common/certs`
2. Generate self-signed key and certificate pair in one go for `ssl.dev`. `$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ssl.dev.key -out ssl.dev.crt` Note: `-keyout` and `-out` names: `{VIRTUAL_HOST}.key` and `{VIRTUAL_HOST}.crt`
3. When generating certificates, ensure you use the *Common Name* as `ssl.dev`. It is possible to generate a default certificate that serves all top-level domains, but as far as I know there are some browsers that DO NOT support `wildcard domains` at the top-level. In order to use the wildcard domains, I believe you need to use a base domain name such as `myapps.dev` and virtual host names like `apache.myapps.dev`, `nginx.myapps.dev`, `ssl.myapps.dev` and so on. So in this case, default certificate can have the Common Name `*.myapps.dev` and the file names can be `default.key` and `default.crt`.
4. Restart the nginx-proxy container.
5. Restart the virtual host container.

NOTE: Because we are treating the backend non-ssl, there is nothing to modify on the virtual host container side. If the SSL Backend must support SSL, supply `VIRTUAL_PROTO=https`, `VIRTUAL_PORT=443` and `HTTPS_METHOD=nohttp` to the environment but this requires you to modify vhost.conf which I will not cover here.

NOTE: Because we are using self-signed certificates, you'd normally go through to [add an exception as shown here.](https://s0.cyberciti.org/images/faq/2013/11/self-signed-certificate-warning.png).