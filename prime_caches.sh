#!/bin/sh

ab -n 500 -k -q -S -d -t 10 http://0.0.0.0:10001/main/questions?count=5
