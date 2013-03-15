#!/bin/bash

set -e 
cd /srv/keks

export PATH=/afs/mathi.uni-heidelberg.de/home/keks/gems/bin:$PATH
export GEM_HOME=/afs/mathi.uni-heidelberg.de/home/keks/gems
export GEM_PATH=/afs/mathi.uni-heidelberg.de/home/keks/gems
alias ruby="/usr/bin/ruby1.9.1"
alias gem="/usr/bin/gem1.9.1"

bundle exec rails server -p 10001 -b localhost > /dev/null > 2>&1 &
echo $! > /var/run/keks.pid
