# Run in docker

Simple and fast setup of VEST.IO on Docker is also available.

## Install Dependencies

- [Docker](https://docs.docker.com) Docker 17.05 or higher is required
- [docker-compose](https://docs.docker.com/compose/) version >= 1.10.0

## Docker Requirement

- At least 7GB RAM (Docker -> Preferences -> Advanced -> Memory -> 7GB or above)
- If the build below fails, make sure you've adjusted Docker Memory settings and try again.

## Build vest image

```bash
git clone https://github.com/VESTIO/vest.git --recursive  --depth 1
cd vest/Docker
docker build . -t vestio/vest
```

The above will build off the most recent commit to the master branch by default. If you would like to target a specific branch/tag, you may use a build argument. For example, if you wished to generate a docker image based off of the v1.2.3 tag, you could do the following:

```bash
docker build -t vestio/vest:v1.2.3 --build-arg branch=v1.2.3 .
```

By default, the symbol in vestio.system is set to SYS. You can override this using the symbol argument while building the docker image.

```bash
docker build -t vestio/vest --build-arg symbol=<symbol> .
```

## Start nodvest docker container only

```bash
docker run --name nodvest -p 8888:8888 -p 9876:9876 -t vestio/vest nodvestd.sh -e --http-alias=nodvest:8888 --http-alias=127.0.0.1:8888 --http-alias=localhost:8888 arg1 arg2
```

By default, all data is persisted in a docker volume. It can be deleted if the data is outdated or corrupted:

```bash
$ docker inspect --format '{{ range .Mounts }}{{ .Name }} {{ end }}' nodvest
fdc265730a4f697346fa8b078c176e315b959e79365fc9cbd11f090ea0cb5cbc
$ docker volume rm fdc265730a4f697346fa8b078c176e315b959e79365fc9cbd11f090ea0cb5cbc
```

Alternately, you can directly mount host directory into the container

```bash
docker run --name nodvest -v /path-to-data-dir:/opt/vestio/bin/data-dir -p 8888:8888 -p 9876:9876 -t vestio/vest nodvestd.sh -e --http-alias=nodvest:8888 --http-alias=127.0.0.1:8888 --http-alias=localhost:8888 arg1 arg2
```

## Get chain info

```bash
curl http://127.0.0.1:8888/v1/chain/get_info
```

## Start both nodvest and kvestd containers

```bash
docker volume create --name=nodvest-data-volume
docker volume create --name=kvestd-data-volume
docker-compose up -d
```

After `docker-compose up -d`, two services named `nodvestd` and `kvestd` will be started. nodvest service would expose ports 8888 and 9876 to the host. kvestd service does not expose any port to the host, it is only accessible to clvest when running clvest is running inside the kvestd container as described in "Execute clvest commands" section.

### Execute clvest commands

You can run the `clvest` commands via a bash alias.

```bash
alias clvest='docker-compose exec kvestd /opt/vestio/bin/clvest -u http://nodvestd:8888 --wallet-url http://localhost:8900'
clvest get info
clvest get account inita
```

Upload sample exchange contract

```bash
clvest set contract exchange contracts/exchange/
```

If you don't need kvestd afterwards, you can stop the kvestd service using

```bash
docker-compose stop kvestd
```

### Develop/Build custom contracts

Due to the fact that the vestio/vest image does not contain the required dependencies for contract development (this is by design, to keep the image size small), you will need to utilize the vestio/vest-dev image. This image contains both the required binaries and dependencies to build contracts using vestiocpp.

You can either use the image available on [Docker Hub](https://hub.docker.com/r/vestio/vest-dev/) or navigate into the dev folder and build the image manually.

```bash
cd dev
docker build -t vestio/vest-dev .
```

### Change default configuration

You can use docker compose override file to change the default configurations. For example, create an alternate config file `config2.ini` and a `docker-compose.override.yml` with the following content.

```yaml
version: "2"

services:
  nodvest:
    volumes:
      - nodvest-data-volume:/opt/vestio/bin/data-dir
      - ./config2.ini:/opt/vestio/bin/data-dir/config.ini
```

Then restart your docker containers as follows:

```bash
docker-compose down
docker-compose up
```

### Clear data-dir

The data volume created by docker-compose can be deleted as follows:

```bash
docker volume rm nodvest-data-volume
docker volume rm kvestd-data-volume
```

### Docker Hub

Docker Hub image available from [docker hub](https://hub.docker.com/r/vestio/vest/).
Create a new `docker-compose.yaml` file with the content below

```bash
version: "3"

services:
  nodvestd:
    image: vestio/vest:latest
    command: /opt/vestio/bin/nodvestd.sh --data-dir /opt/vestio/bin/data-dir -e --http-alias=nodvestd:8888 --http-alias=127.0.0.1:8888 --http-alias=localhost:8888
    hostname: nodvestd
    ports:
      - 8888:8888
      - 9876:9876
    expose:
      - "8888"
    volumes:
      - nodvest-data-volume:/opt/vestio/bin/data-dir

  kvestd:
    image: vestio/vest:latest
    command: /opt/vestio/bin/kvestd --wallet-dir /opt/vestio/bin/data-dir --http-server-address=127.0.0.1:8900 --http-alias=localhost:8900 --http-alias=kvestd:8900
    hostname: kvestd
    links:
      - nodvestd
    volumes:
      - kvestd-data-volume:/opt/vestio/bin/data-dir

volumes:
  nodvest-data-volume:
  kvestd-data-volume:

```

*NOTE:* the default version is the latest, you can change it to what you want

run `docker pull vestio/vest:latest`

run `docker-compose up`

### VESTIO Testnet

We can easily set up a VESTIO local testnet using docker images. Just run the following commands:

Note: if you want to use the mongo db plugin, you have to enable it in your `data-dir/config.ini` first.

```
# create volume
docker volume create --name=nodvest-data-volume
docker volume create --name=kvestd-data-volume
# pull images and start containers
docker-compose -f docker-compose-vestio-latest.yaml up -d
# get chain info
curl http://127.0.0.1:8888/v1/chain/get_info
# get logs
docker-compose logs -f nodvestd
# stop containers
docker-compose -f docker-compose-vestio-latest.yaml down
```

The `blocks` data are stored under `--data-dir` by default, and the wallet files are stored under `--wallet-dir` by default, of course you can change these as you want.

### About MongoDB Plugin

Currently, the mongodb plugin is disabled in `config.ini` by default, you have to change it manually in `config.ini` or you can mount a `config.ini` file to `/opt/vestio/bin/data-dir/config.ini` in the docker-compose file.
