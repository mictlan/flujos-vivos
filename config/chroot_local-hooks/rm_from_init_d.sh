#!/bin/sh
SERVICES="icecast2 mpd ssh samba clamav-freshclam cups"

for service in $SERVICES; do 
    update-rc.d -f "$service" remove
done
