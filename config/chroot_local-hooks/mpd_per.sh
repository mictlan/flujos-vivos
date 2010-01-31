#!/bin/sh

#change ownership of /var/log/mpd to radio

# Use ntfs-3g by default to mount ntfs partitions

if [ -x /usr/bin/mpd ]

then

        chown -R 1000 /var/log/mpd
fi
