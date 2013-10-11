#!/bin/sh

set -e

export COVERAGE=true

USE_THREADS=`/usr/bin/nproc`

echo "Using $USE_THREADS threads"
echo "Creating test.sqlite3"
rake "parallel:create[1]" "parallel:prepare[1]" > /dev/null

echo "Copying test.sqlite3 for additional threads"
for i in `seq 2 $USE_THREADS`; do
  cp "db/test.sqlite3" "db/test${i}.sqlite3"&
done
wait

rake "parallel:spec[$USE_THREADS]"

echo "\n\n\n\nx-www-browser ./coverage/index.html"
