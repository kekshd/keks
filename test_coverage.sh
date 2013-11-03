#!/bin/sh

set -e

export COVERAGE=true

USE_THREADS=`/usr/bin/nproc`

echo "Using $USE_THREADS threads"
if [ ! -s "db/test.sqlite3" ]; then
  echo "Setting up test DB"
  zeus rake db:test:prepare
fi

echo "Copying test.sqlite3 for additional threads"
for i in `seq 2 $USE_THREADS`; do
  cp "db/test.sqlite3" "db/test${i}.sqlite3"&
done
wait

RAILS_ENV=test rake "parallel:spec[$USE_THREADS]"

echo "\n\n\n\nx-www-browser ./coverage/index.html"
