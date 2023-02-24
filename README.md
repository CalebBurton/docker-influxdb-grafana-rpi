# Docker Image with InfluxDB and Grafana

This is a Docker image initially inspired by the
[Docker Image with InfluxDB and Grafana](https://github.com/philhawthorne/docker-influxdb-grafana)
repo from [Phil Hawthorne](https://github.com/philhawthorne), with improvements
for running on a Raspberry Pi as suggested by
[ronaldn1969](https://github.com/ronaldn1969) in
[this issue comment](https://github.com/philhawthorne/docker-influxdb-grafana/issues/57#issuecomment-1049649757).

It has since been heavily modified, and now uses the official images for both
influxdb and grafana rather than Phil's combined Dockerfile.

## Initialize a Fresh Raspberry Pi

```sh
# Update packages
sudo apt update
sudo apt upgrade -y
sudo reboot

# Install docker
# Modified from https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-debian-10
sudo apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
apt-cache policy docker-ce # just to confirm you're pointed at the right docker repo
sudo apt install -y docker-ce
sudo systemctl status docker # confirm everything worked

# Add yourself to the "docker" group
echo $USER
sudo usermod -aG docker ${USER}
su - ${USER}
id -nG # confirm "docker" is one of the groups

# Configure git
git config --global user.email "EMAIL@EXAMPLE.COM"
git config --global user.name "FIRST LAST"

# Make an SSH key and copy it to your clipboard
ssh-keygen
cat ~/.ssh/id_rsa.pub

# Add the key to github by visiting https://github.com/settings/ssh/new

# Clone this repository
git clone git@github.com:CalebBurton/docker-influxdb-grafana-rpi.git
cd docker-influxdb-grafana-rpi

# Add `cd ~/docker-influxdb-grafana-rpi` to the last line of your bashrc
sudo vi ~/.bashrc

# Synchronize config data and `.env` files

# Restart
sudo reboot
```

If using a USB drive as the data location, make sure to mount it properly:

```sh
# Find the uuid
sudo blkid

# Add it to fstab
sudo vi /etc/fstab
# The file should look something like this:
#####################################################################
# # device-spec   mount-point     fs-type options           dump pass
# [...]
# /dev/sdc1      /media/pi/usb auto uid=pi,gid=pi,umask=0000 0    0
#####################################################################
```

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

From the machine running the docker container:

```sh
# Note that it can take a long time after the container starts before
# the database is ready for connections
docker exec -it influxdb influx
```

From remote machines, use the influxdb-cli tool (`brew install influxdb-cli`).
[Reference docs](https://docs.influxdata.com/influxdb/cloud/tools/influx-cli/).

```sh
influx config create --config-name <config-name> \
  --host-url http://example.com:8086 \
  --org <your-org> \
  --token <your-auth-token> \
  --active

influx ping
influx query "QUERY"
```

Once you're in, use the influxdb query language.
[Reference](https://docs.influxdata.com/influxdb/v1.8/query_language/explore-schema/).

```influxdb
show databases
use DATABASE_NAME
show measurements
# Timestamps are in nanoseconds, so 1677265800000000000 is 2023/02/24
select * from "MEASUREMENT" where time > TIMESTAMP
```

## Backups

Adapted from <https://crycode.de/nextcloud-client-auf-dem-raspberry-pi>

1. Install the Nextcloud command line tool

  ```sh
  sudo apt update && sudo apt install -y nextcloud-desktop-cmd
  ```

1. Create a file at `~/.netrc` with the contents

  ```txt
  machine YOUR_NEXTCLOUD_SERVER_HERE
          login YOUR_USERNAME_HERE
          password YOUR_PASSWORD_HERE
  ```

1. Change the ownership with `chmod 0600 ~/.netrc`
1. Modify `./.env` with the path where you're storing the data
1. Run it daily with crontab. Run `crontab -e` and add the following:

  ```sh
  # [...]
  # Run the sync script daily at 4am
  0 4 * * * /home/pi/cloud-sync.sh >/dev/null &
  ```

1. The result of the synchronization can be viewed in the log file described in
`./.env`. So that the log file can also be written by the user `pi`,
we have to create it first and adjust the rights accordingly:

  ```sh
  sudo mkdir -p path/to/logfile/folder
  sudo touch path/to/logfile.log
  sudo chown pi:pi path/to/logfile.log
  ```

1. So that the log file doesn't become infinitely large, create a logrotate
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
