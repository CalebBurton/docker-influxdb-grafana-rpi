#!/bin/bash
LOCAL=/media/pi/128GB-1/Influx-Grafana/
ZIP_DIR=/media/pi/128GB-1/Compressed
ZIP_FILE=Influx-Grafana
REMOTE=https://brtn.dev/remote.php/webdav/Projects/Influx-Grafana

# Additional details at
#  https://manpages.debian.org/bullseye/nextcloud-desktop-cmd/nextcloudcmd.1.en.html

LOG=/home/pi/Desktop/logs/cloud-sync.log

if [ "$(pgrep -x nextcloudcmd)" ]; then
  echo "====================" | tee -a $LOG
  date -R | tee -a $LOG
  echo "Cloud sync is already running!" | tee -a $LOG
  echo "====================" | tee -a $LOG
  exit 1
fi

echo "====================" | tee -a $LOG
date -R | tee -a $LOG
echo "Removing old zip files" | tee -a $LOG
echo "====================" | tee -a $LOG

rm -rf "${ZIP_DIR:?}"/*

echo "====================" | tee -a $LOG
date -R | tee -a $LOG
echo "Zip creation started" | tee -a $LOG
echo "====================" | tee -a $LOG

# Zip up the files to avoid sync conflicts

# -9: highest compression level
# -q: quiet
# -r: recurse subdirectories
# -s 1g: split into 1GB pieces
zip -9 -q -r -s 1g "$ZIP_DIR"/"$ZIP_FILE" "$LOCAL"

echo "====================" | tee -a $LOG
date -R | tee -a $LOG
echo "Zip creation completed" | tee -a $LOG
echo "====================" | tee -a $LOG

echo "====================" | tee -a $LOG
date -R | tee -a $LOG
echo "Cloud sync started" | tee -a $LOG
echo "====================" | tee -a $LOG

# Actually run the synchronization

# --non-interactive: just what it sounds like
# -n: use $HOME/.netrc file for username/password
nextcloudcmd --non-interactive -n "$ZIP_DIR" "$REMOTE" 2>&1 | tee -a $LOG

echo "====================" | tee -a $LOG
date -R | tee -a $LOG
echo "Cloud sync completed" | tee -a $LOG
echo "====================" | tee -a $LOG
