#!/bin/sh

bundle exec rake assets:precompile:all
bundle exec rake sunspot:solr:start
bundle exec rake sunspot:solr:reindex &
bundle exec rails server -b 0.0.0.0
