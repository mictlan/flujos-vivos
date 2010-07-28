#!/bin/sh
# 
# you might run this one from cron. it recordes from jackd 
# from the pors specified for the duration specified. 
# Then encodes to OGG. 
# leaving us with a 3 channel vorbis file :)
# http://xiph.org/vorbis/doc/Vorbis_I_spec.html#x1-800004.3.9
#
# jack ports to record

PORTS0="system:capture_1"

# mpd disconnects on song change so commenting out for now. 
#PORTS1="MPD:left MPD:right" 

# format time stamp
STIME=$(date +%F_%R)

# save previos jackrec pid
OLD_JACKREC=$(pgrep jackrec)

# 15min/2secs = 902sec
DURATION="902"
ARCHIVE_DIR="/home/radioplanton/Audios/acervo"

# output files name
VFNAME="radioplanton-locucion_${STIME}"
VFOUT="${ARCHIVE_DIR}/${VFNAME}"

#MFNAME="radioplanton-musica_${STIME}"
#MFOUT="${ARCHIVE_DIR}/${MFNAME}"

# move to file dir
cd ${ARCHIVE_DIR}

# record to wav
# first instance of jackrec is voice from system:in
jackrec -d ${DURATION} -f ${VFOUT}.wav ${PORTS0} & > /dev/null 2>&1

# save pid to file
echo $! > /tmp/sysrec.pid

# second instance of jackrec is music from mpd
#jackrec -d ${DURATION} -f ${MFOUT} ${PORTS1} & > /dev/null 2>&1

# save variable so we dont overwrite it
echo "VFNAME=$VFNAME" > /tmp/cola-locucion.tmp

#echo "MFNAME=$MFNAME" > /tmp/cola-musica.tmp

# encode
/usr/local/bin/iceenc.sh &>  /dev/null 2>&1
wait $!

mv /tmp/cola-locucion.tmp /tmp/cola-locucion

