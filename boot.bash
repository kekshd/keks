#!/bin/bash

set -e
cd /srv/keks

export PATH=/srv/keks/GEMS/bin:$PATH
export GEM_HOME=/srv/keks/GEMS
export GEM_PATH=/srv/keks/GEMS
alias ruby="/usr/bin/ruby1.9.1"
alias gem="/usr/bin/gem1.9.1"

#export RAILS_ENV=development
export RAILS_ENV=production

export RAILS_RELATIVE_URL_ROOT=/keks
[ -e ".SECRET_TOKEN" ] && export SECRET_TOKEN=$(cat .SECRET_TOKEN)


bundle exec rails server -p 10001 -b localhost --daemon >> /srv/keks/log/daemon.log 2>&1

# if the bash script is killed, make sure the server
# goes down with it
trap "kill $!" TERM
wait

