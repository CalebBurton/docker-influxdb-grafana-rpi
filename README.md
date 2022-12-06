# Docker Image with InfluxDB and Grafana

This is a Docker image initially inspired by the
[Docker Image with InfluxDB and Grafana](https://github.com/philhawthorne/docker-influxdb-grafana)
repo from [Phil Hawthorne](https://github.com/philhawthorne), with improvements
for running on a Raspberry Pi as suggested by
[ronaldn1969](https://github.com/ronaldn1969) in
[this issue comment](https://github.com/philhawthorne/docker-influxdb-grafana/issues/57#issuecomment-1049649757).

It has since been heavily modified, and now uses the official images for both
influxdb and grafana rather than Phil's combined Dockerfile.

## Quick Start

To start the container with persistence you can save the
`docker-compose.yml.example` file as `docker-compose.yml`, modifying the
directory paths as needed, and run `docker compose up`.

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

As of late 2020, new versions of popular browsers (including Chrome and
Firefox) are enforcing cookies set without HTTPs must originate from the same
domain/host. This means if you have Home Assistant and Grafana running on
different IP addresses/hosts in your local network, you must use HTTPs with
this container. If you don't, you are unable to login to Grafana when accessing
Grafana from a `panel_iframe`.

Generate a self-signed IP certificate by running the
`./generate-self-signed-ip-cert.sh` script.

## InfluxDB

### InfluxDB Shell (CLI)

```sh
docker exec -it influxdb influx
```

## Backups

Adapted from <https://crycode.de/nextcloud-client-auf-dem-raspberry-pi>

1. Create a file at `~/.netrc` with the contents

  ```txt
  machine YOUR_NEXTCLOUD_SERVER_HERE
          login YOUR_USERNAME_HERE
          password YOUR_PASSWORD_HERE
  ```

2. Change the ownership with `chmod 0600 ~/.netrc`
3. Modify `./cloud-sync.sh` with the path where you're storing the data
4. Run it daily with chrontab. Run `crontab -e` and add the following:

  ```sh
  # [...]
  # Run the sync script daily at 4am
  0 4 * * * /home/pi/cloud-sync.sh >/dev/null &
  ```

5. The result of the synchronization can be viewed in the log file described in
`./cloud-sync.sh`. So that the log file can also be written by the user `pi`,
we have to create it first and adjust the rights accordingly:

  ```sh
  sudo touch path/to/logfile.log
  sudo chown pi:pi path/to/logfile.log
  ```

6. So that the log file doesn't become infinitely large, create a logrotate
configuration for this file. Create a file at `/etc/logrotate.d/cloud-sync` and
edit it with the following contents:

  ```sh
path/to/logfile.log {
  weekly
  missingok
  rotate 4
  compress
  delaycompress
  notifempty
  create 640 pi pi
}
  ```

  This rotates the logs into a new file once a week, keeping the the last four
  copies.
