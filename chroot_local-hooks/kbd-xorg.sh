#!/bin/sh

echo "changing XkbLatyout to latam,us"

sed -i -e '/XkbLayout/c\    Option      "XkbLayout" "latam,us"'    /etc/X11/xorg.conf

