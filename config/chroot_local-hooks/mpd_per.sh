#!/bin/sh

#change ownership of /var/log/mpd to radio

if [ -x /usr/bin/mpd ]

then

        chown -R 1000 /var/log/mpd
fi
