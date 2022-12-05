#!/bin/bash
LOCAL=/media/pi/128GB-1/Nextcloud/Projects/Influx-Grafana/
REMOTE=https://brtn.dev/remote.php/webdav/Projects/Influx-Grafana
PARAMS="--non-interactive -n -h"

# Additional details at
#  https://manpages.debian.org/bullseye/nextcloud-desktop-cmd/nextcloudcmd.1.en.html

LOG=/home/pi/Desktop/logs/cloud-sync.log

if [ $(pgrep -x nextcloudcmd) ]; then
  echo "====================" | tee -a $LOG
  date -R | tee -a $LOG
  echo "Cloud sync is already running!" | tee -a $LOG
  echo "====================" | tee -a $LOG
  exit 1
fi

echo "====================" | tee -a $LOG
date -R | tee -a $LOG
echo "Cloud sync started" | tee -a $LOG
echo "====================" | tee -a $LOG

# Actually run the synchronization
nextcloudcmd $PARAMS $LOCAL $REMOTE 2>&1 | tee -a $LOG

echo "====================" | tee -a $LOG
date -R | tee -a $LOG
echo "Cloud sync completed" | tee -a $LOG
echo "====================" | tee -a $LOG