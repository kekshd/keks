#!/bin/sh

rm -f tmp/pids/server.pid
bundle exec rake db:migrate
bundle exec rake assets:precompile:all
bundle exec rake sunspot:solr:start
bundle exec rake sunspot:solr:reindex &
mkdir -p /usr/src/app/log
bundle exec rails server -b 0.0.0.0  > >(tee -a /usr/src/app/log/stdout.log) 2> >(tee -a /usr/src/app/log/stderr.log >&2)
