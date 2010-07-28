#!/bin/sh
# 
# resample wav and encode to wideband speex
#
# another option would be vorbis surround
# leaving us with a 3 channel vorbis file :)
# http://xiph.org/vorbis/doc/Vorbis_I_spec.html#x1-800004.3.9
#
# Encodr and options
 
XIPH_ENC=/usr/bin/speexenc
ENC_OPTIONS='-w --vbr --dtx --comment app="icrec.sh" --title="Cabina Radio Planton" --author="Radio Planton"'

ARCHIVE_DIR="/home/radioplanton/Audios/acervo"

# move to file dir
cd ${ARCHIVE_DIR}

# wait for recording to end
SYSREC=$(cat /tmp/sysrec.pid)
kill -0 ${SYSREC} >/dev/null

# encode voice to speex
if [ -f /tmp/cola-locucion ]
 then
  . /tmp/cola-locucion 

  # resample to 8000hz
  sndfile-resample -to 16000 -c 0 ${VFNAME}.wav ${VFNAME}-rs.wav  &> /dev/null 2>&1
  wait $!
  # encode to speex 
  ${XIPH_ENC} ${ENC_OPTS} ${VFNAME}-rs.wav ${VFNAME}.spx  &> /dev/null 2>&1
  wait $! 
 
  # BUILD HTML
  /usr/local/bin/html.py > /var/www/radioplanton/index.html

  # delete rs and original wav if speex file exists 
  if [ -f ${VFNAME}.spx  ]
   then
   rm ${VFNAME}-rs.wav
   rm ${VFNAME}.wav
  fi
fi

