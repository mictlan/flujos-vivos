#!/bin/sh
SERVICES="icecast2 mpd"

for service in $SERVICES; do 
    update-rc.d -f "$service" remove
done
