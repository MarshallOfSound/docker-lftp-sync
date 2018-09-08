#!/bin/bash
login=$LFTP_USER
pass=$LFTP_PASSWORD
host=$LFTP_HOST
base_remote_dir=$LFTP_REMOTE_DIR
base_local_dir=/media

trap "rm -f /config/synctorrent.lock" SIGINT SIGTERM

set -e

if [ -e /config/synctorrent.lock ]
then
  echo "Sync is running already."
  exit 1
else
  touch /config/synctorrent.lock
  

sync_dir() {

remote_dir=$base_remote_dir/$1
local_dir=$base_local_dir/$1

echo "Syncing $remote_dir --> $local_dir"

mkdir -p $local_dir

lftp  << EOF
set mirror:use-pget-n 2
lftp -u $login,$pass $host
mirror -c -P5 --no-perms --dereference $remote_dir $local_dir
quit
EOF

}

  echo "Sync Starting: $(date)"

  old_ifs=$IFS
  export IFS=";"
  for dir in $LFTP_DIRS; do
    export IFS=$old_ifs
    sync_dir "$dir"
    export IFS=";"
  done

  echo "Sync Done: $(date)"

  rm -f /config/synctorrent.lock
  exit 0
fi