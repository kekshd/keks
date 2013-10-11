#!/bin/sh

COVERAGE=true rake
echo "\n\nx-www-browser ./coverage/index.html"
