#!/bin/sh

cd $(dirname $0)
cd ..
wget --quiet -O - "http://www.yrden.de/share/bundler/keks.tar.xz" | tar -xJf -

# if the server is down or the file corrupt, contine install normally
exit 0

