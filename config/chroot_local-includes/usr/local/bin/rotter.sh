#!/bin/sh

ARCHIVE_DIR="/home/radioplanton/Audios/acervo"

# rotter records vorbis a 160 bits / sec. 
/usr/bin/rotter -L flat -N radioplanton -n sysrec -c2 -f vorbis -d 48 -b 160  -q $ARCHIVE_DIR

