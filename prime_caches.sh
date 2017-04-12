#!/bin/sh

ab -n 1 -k -q -S -d http://0.0.0.0:10001/main/questions?count=5 > /dev/null 2> /dev/null
