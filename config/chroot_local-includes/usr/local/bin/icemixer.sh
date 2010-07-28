#!/bin/bash

# icemixer-screen.sh
# launches darkice, ecasignalview, and alsamixer
# within screen for a simultaneous console view
# of mic levels, mixer, and darkice output

# set console font to the smallest size
setfont /usr/share/consolefonts/lat0-08.psf.gz

IUSER=radioplanton

# create a custom screenrc just for flujos
cat > /home/${IUSER}/.screenrc-flujos <<-EOF
	startup_message off
	screen 0 /usr/bin/ecasignalview -o alsa
	split
	resize 12
	focus
	screen 1 /usr/bin/darkice
	split -v
	focus
	screen 2 /usr/bin/alsamixer -V capture
EOF

# dismiss ecasignalview whining
export ECASOUND=ecasound

# ensure darkice.cfg defaults to alsa
sudo sed -i '/^device/s/jack/default/' /etc/darkice.cfg
#sudo sed -i '/^server/s/localhost/$1/' /etc/darkice.cfg

# launch icecast server
pgrep icecast2 || sudo /etc/init.d/icecast2 start

# launch screen with custom screenrc
screen -c /home/radio/.screenrc-flujos

# THE END
