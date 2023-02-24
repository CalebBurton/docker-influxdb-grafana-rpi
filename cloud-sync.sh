#!/bin/bash
source ./.env

if [[ -z "$ZIP_DIR" ]]; then
    echo "Must provide ZIP_DIR in environment" 1>&2
    exit 1
fi
if [[ -z "$ZIP_FILE_NAME" ]]; then
    echo "Must provide ZIP_FILE_NAME in environment" 1>&2
    exit 1
fi
if [[ -z "$REMOTE_URL" ]]; then
    echo "Must provide REMOTE_URL in environment" 1>&2
    exit 1
fi
if [[ -z "$LOG_PATH" ]]; then
    echo "Must provide LOG_PATH in environment" 1>&2
    exit 1
fi

# Additional details at
#  https://manpages.debian.org/bullseye/nextcloud-desktop-cmd/nextcloudcmd.1.en.html

if [ "$(pgrep -x nextcloudcmd)" ]; then
  echo "====================" | tee -a "$LOG_PATH"
  date -R | tee -a "$LOG_PATH"
  echo "Cloud sync is already running!" | tee -a "$LOG_PATH"
  echo "====================" | tee -a "$LOG_PATH"
  exit 1
fi

echo "====================" | tee -a "$LOG_PATH"
date -R | tee -a "$LOG_PATH"
echo "Removing old zip files" | tee -a "$LOG_PATH"
echo "====================" | tee -a "$LOG_PATH"

rm -rf "${ZIP_DIR:?}"/*

echo "====================" | tee -a "$LOG_PATH"
date -R | tee -a "$LOG_PATH"
echo "Zip creation started" | tee -a "$LOG_PATH"
echo "====================" | tee -a "$LOG_PATH"

# Zip up the files to avoid sync conflicts

# -9: highest compression level
# -q: quiet
# -r: recurse subdirectories
# -s 1g: split into 1GB pieces
zip -9 -q -r -s 1g "$ZIP_DIR"/"$ZIP_FILE_NAME" "$LOCAL"

echo "====================" | tee -a "$LOG_PATH"
date -R | tee -a "$LOG_PATH"
echo "Zip creation completed" | tee -a "$LOG_PATH"
echo "====================" | tee -a "$LOG_PATH"

echo "====================" | tee -a "$LOG_PATH"
date -R | tee -a "$LOG_PATH"
echo "Cloud sync started" | tee -a "$LOG_PATH"
echo "====================" | tee -a "$LOG_PATH"

# Actually run the synchronization

# --non-interactive: just what it sounds like
# -n: use $HOME/.netrc file for username/password
nextcloudcmd --non-interactive -n "$ZIP_DIR" "$REMOTE_URL" 2>&1 | tee -a "$LOG_PATH"

echo "====================" | tee -a "$LOG_PATH"
date -R | tee -a "$LOG_PATH"
echo "Cloud sync completed" | tee -a "$LOG_PATH"
echo "====================" | tee -a "$LOG_PATH"
