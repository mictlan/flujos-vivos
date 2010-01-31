#!/bin/sh
#/usr/bin/jackd -R -dalsa -dhw:0 -r44100 -p1024 -n2 2> /dev/null &
jack.ctl start 2> /dev/null &
