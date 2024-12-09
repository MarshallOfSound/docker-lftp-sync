#!/bin/bash
source /env.sh

login=$LFTP_USER
pass=$LFTP_PASSWORD
host=sftp://$LFTP_HOST
base_remote_dir=$LFTP_REMOTE_DIR
base_local_dir=/media
parallel=${LFTP_PARALLEL:-4}

set -e

if [ -e /config/lftp-sync.lock ]
then
  echo "Sync is running already."
  exit 1
else
  touch /config/lftp-sync.lock

trap "rm -f /config/lftp-sync.lock" EXIT

sync_dir() {

remote_dir=$base_remote_dir/$1
local_dir=$base_local_dir/$1

if [ -d "$local_dir" ]
then
	if [ "$(ls -A $local_dir)" ]; then
    echo "Syncing $remote_dir --> $local_dir"
    
    mkdir -p $local_dir
    
    lftp  << EOF
    set sftp:auto-confirm yes
    set mirror:use-pget-n 4
    lftp -u $login,$pass $host
    mirror -c -P=$parallel --no-perms --dereference --Remove-source-files --log=/var/log/lftp.log -x ^[^\\/]*$ -vvv $remote_dir $local_dir
    quit
EOF
  else
    echo "Skipping $remote_dir .. $local_dir is empty"
  fi
fi

echo "sync_dir() done"

}

  echo "Sync Starting: $(date)"

  old_ifs=$IFS
  export IFS=";"
  for dir in $LFTP_DIRS; do
    export IFS=$old_ifs
    sync_dir "$dir"
    export IFS=";"
  done
  export IFS=$old_ifs

  echo "Sync Done: $(date)"

  rm -f /config/lftp-sync.lock
  exit 0
fi
