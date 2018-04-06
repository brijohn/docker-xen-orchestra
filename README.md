# Xen Orchestra Docker Container
> stable 5.x branch of [Xen Orchestra](http://xen-orchestra.com/)

## Image Installation

From Docker Hub:

```sh
docker pull brijohn/xen-orchestra
```
From Source:

```sh
git clone https://github.com/brijohn/docker-xen-orchestra.git
cd docker-xen-orchestra
docker build -t "xen-orchestra:latest" --rm --no-cache .
```


## Running the Container

Create a set of volumes used to store the XO databases.

```sh
docker volume create --name xo-redis
docker volume create --name xo-server
docker volume create --name xo-backup
```

Next launch the container using the previously created volumes.

```sh
docker run -d -p 8000:8000  -v xo-redis:/var/lib/redis \
-v xo-server:/var/lib/xo-server \
-v xo-backup:/var/lib/xoa-backup \
--name xen-orchestra brijohn/xen-orchestra
```

## Log Files

Use docker's logging functionality to print out the xo-server log file.

```sh
docker logs xen-orchestra
```

## Adding SSL support

If SSL support is needed, you will need to rebuild the container after modifying the xo-server.yaml
file by adding lines specifying the certificate and key file.

#### Example SSL yaml file
```yaml
user: 'app'
http:
  listen:
    -
      host: '0.0.0.0'
      port: 8000
      cert: <path/to/cert/file>
      key:  <path/to/key/file>
  mounts:
    '/': '/app/xo-web/dist/'
redis:
    uri: 'tcp://localhost:6379'
```
For a full list of SSL/TLS options see: [NodeJS:tls.createServer](https://nodejs.org/docs/latest/api/tls.html#tls_tls_createserver_options_secureconnectionlistener)


## Author

Brian Johnson - [Github](https://github.com/brijohn/) - brijohn@gmail.com

Distributed under the GPL 3 license. See ``LICENSE`` for more information.
