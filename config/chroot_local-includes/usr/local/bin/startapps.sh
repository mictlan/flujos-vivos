# tipo
TYPE=ppm
NAME=ice-${TYPE}

# start darkice if not already runing
pgrep darkice || /usr/bin/darkice & > /dev/null 2>&1

# uncomment to start jack-rack
#pgrep jack-rack || /usr/bin/jack-rack /home/radioplanton/.jack-rack.cfg & > /dev/null 2>&1

# start jack.plumbing for predifined connections between clients
pgrep jack.plumbing || /usr/bin/jack.plumbing & > /dev/null 2>&1

# start mpd if it is not running
pgrep mpd || /usr/bin/mpd & > /dev/null 2>&1

# push play on mpd, just incase
/usr/bin/mpc play & > /dev/null 2>&1

