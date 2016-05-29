# Xen Orchestra Docker Container
> stable 4.x branch of [Xen Orchestra](http://xen-orchestra.com/)

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

There are two options for starting the container.

1) Run container without using database volumes
```sh
docker run -d -p 8000:8000 --name xen-orchestra brijohn/xen-orchestra
```
2) Mount XO data store on host filesystem
```sh
docker volume create --name xo-redis
docker volume create --name xo-server
docker run -d -p 8000:8000  -v xo-redis:/var/lib/redis -v xo-server:/var/lib/xo-server \
--name xen-orchestra brijohn/xen-orchestra
```



## Author

Brian Johnson - [Github](https://github.com/brijohn/) - brijohn@gmail.com

Distributed under the GPL 3 license. See ``LICENSE`` for more information.
