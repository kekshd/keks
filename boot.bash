#!/bin/bash

set -e
cd /srv/keks

export PATH=/afs/mathi.uni-heidelberg.de/home/keks/gems/bin:$PATH
export GEM_HOME=/afs/mathi.uni-heidelberg.de/home/keks/gems
export GEM_PATH=/afs/mathi.uni-heidelberg.de/home/keks/gems
alias ruby="/usr/bin/ruby1.9.1"
alias gem="/usr/bin/gem1.9.1"

export RAILS_ENV=development
#export RAILS_ENV=production

export RAILS_RELATIVE_URL_ROOT=/keks

bundle exec rails server -p 10001 -b localhost >> /srv/keks/log/daemon.log 2>&1

#echo $! > /var/run/keks.pid
