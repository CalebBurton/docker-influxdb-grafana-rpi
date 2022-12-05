# Docker Image with InfluxDB and Grafana

This is a Docker image based on the [Docker Image with InfluxDB and Grafana](https://github.com/philhawthorne/docker-influxdb-grafana) repo from [Phil Hawthorne](https://github.com/philhawthorne), with improvements for running on a Raspberry Pi as suggested by [ronaldn1969](https://github.com/ronaldn1969) in [this issue comment](https://github.com/philhawthorne/docker-influxdb-grafana/issues/57#issuecomment-1049649757).

## Quick Start

To start the container with persistence you can save the
`docker-compose.yml.example` file as `docker-compose.yml`, modifying the
directory paths as needed, and run `docker compose up`.

## Mapped Ports

| Host | Container |  Service   |
|------|-----------|------------|
| 3003 | 3003      | grafana    |
| 3004 | 8083      | chronograf |
| 8086 | 8086      | influxdb   |

## Grafana

Open <http://localhost:3003>

- Username: `root`
- Password: `root`

### Add data source on Grafana

1. Using the wizard click on `Add data source`
2. Select InfluxDB
3. Leave everything as the default, with the following updates:
  - HTTP
      - url: `http://localhost:8086`
  - InfluxDB Details
      - database: `_internal`
      - user: `root`
      - password: `root`
5. Click add without altering other fields


Now you are ready to add your first dashboard and launch some queries on a database.

### Embedding inside Home Assistant

Home Assistant allows services to be embedded using the `panel_iframe` feature.

As of late 2020, new versions of popular browsers (including Chrome and Firefox) are enforcing cookies set without HTTPs must originate from the same domain/host. This means if you have Home Assistant and Grafana running on different IP addresses/hosts in your local network, you must use HTTPs with this container. If you don't, you are unable to login to Grafana when accessing Grafana from a `panel_iframe`.

You can still access Grafana without enabling HTTPs by accessing the host IP/name directly in your browser (ie not in an iFrame).

## InfluxDB

### Web Interface (Chronograf)

Open <http://localhost:3004>

- Username: `root`
- Password: `root`
- Port: `8086`

### InfluxDB Shell (CLI)

1. Establish a ssh connection with the container (see below)
2. Launch `influx` to open InfluxDB Shell (CLI)

## SSH

```sh
docker exec -it <CONTAINER_ID> bash
```
