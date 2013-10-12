#!/bin/sh

set -e

USE_THREADS=`/usr/bin/nproc`

if [ ! -s "db/test.sqlite3" ]; then
  echo "Setting up test DB"
  zeus rake db:test:prepare
fi

if [ -S ".zeus.sock" ]; then
  echo "Using $USE_THREADS threads"
  #~　echo "Creating test.sqlite3"
  #~　zeus rake "parallel:create[1]" "parallel:prepare[1]" > /dev/null

  echo "Copying test.sqlite3 for additional threads"
  for i in `seq 2 $USE_THREADS`; do
    cp "db/test.sqlite3" "db/test${i}.sqlite3"&
  done
  wait

  zeus rake "parallel:spec[$USE_THREADS]"
else
  echo "Start zeus first, please:\n  RAILS_ENV=test zeus start"
fi
