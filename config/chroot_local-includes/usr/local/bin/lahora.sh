#!/bin/bash
# MPD script to play the time of day after the currently playing song. It can be started by a cron job or by commandline.
# 
# Based on playJingle by Marcel van der Schans which in turn was inspired by stop_after_current.sh by Harun Vos.
# http://mpd.wikia.com/wiki/Hack:playJingle
#
# Requires mpc - set the path here.

# if it is not later thatn 11pm and earlier than 6am quit
if [ $(date +%H) -lt 23 ]
 then
   if [ $(date +%H) -gt 6 ]
    then
      exit 0
   fi
fi
if [ $(date +%H) -gt 6 ]
 then
   if [ $(date +%H) -lt 23 ]
    then
      exit 0
   fi
fi

TPATH="$HOME/Música/time" #ruta absoluta hacia biblioteca de la hora
MPCPATH="Música/time" #ruta a la misma pero relativa a biblioteca de mpd

# No cambia los demas valores menos si sabes bien que haces
MPC=mpc
FNAME="lahora.ogg" # nombre de archivo de la hora
JINGLE="$MPCPATH/$FNAME"
# seconds we subtract from timeRemaining 
DMINUS="10"

# Extract the interesting line from the mpc output.
# There must be a nicer way of dealing with multi-line shell variables.
function getDetailsLine()
{
  local d=$($MPC --format "no file name")
  d=$(tail -1 <<EOL
$(head -2 <<EOL2
$d
EOL2)
EOL)
  echo $d
}

# Get the playing/paused status.
function getStateFromLine()
{
  echo $*|cut -d' ' -f1
}

# Get the number of the currently playing song.
function getSongFromLine()
{
  echo $*|cut -d' ' -f2|cut -d'/' -f1|cut -d'#' -f2
}

# Get the number of the last song / the length of the playlist.
function getLastSongFromLine()
{
  echo $*|cut -d' ' -f2|cut -d' ' -f1|cut -d'/' -f2
}

function getDurationMinutes()
{
  echo  $*|cut -d' ' -f3|cut -d'/' -f2|cut -d':' -f1
}

function getDurationSeconds()
{
  echo  $*|cut -d' ' -f3|cut -d'/' -f2|cut -d':' -f2
}

function getPositionMinutes()
{
  echo  $*|cut -d' ' -f3|cut -d'/' -f1|cut -d':' -f1
}
function getPositionSeconds()
{
  echo  $*|cut -d' ' -f3|cut -d'/' -f1|cut -d':' -f2
}
# Dont do anything if we arent playing.
details=$(getDetailsLine)
currState=$(getStateFromLine $details)
if [ "$currState" != "[playing]" ]; then exit; fi

# Add jingle to (end of) playlist.
$MPC add $JINGLE

# Refresh our details line
details=$(getDetailsLine)

currSong=$(getSongFromLine $details)
lastSong=$(getLastSongFromLine $details)

# Move the last song (our jingle) to the next entry.
let nextSong=currSong+1
$MPC move $lastSong $nextSong

# get duration of current song and format it in seconds 
durationMinutes=$(getDurationMinutes $details)
FDM=$((durationMinutes*60))
durationSeconds=$(getDurationSeconds $details)
duration=$(($FDM+$durationSeconds))
# get position of current song and format it in seconds
positionMinutes=$(getPositionMinutes $details)
FPM=$((positionMinutes*60))
positionSeconds=$(getPositionSeconds $details)
position=$(($FPM+$positionSeconds))

# get time remaining by sutracting position from duration
timeRemaining=$(($duration-$position))
timeRemaining=$(($timeRemaining-$DMINUS))

# sleep util current song ends
sleep $timeRemaining

# create current time audio from time library
cat $TPATH/HRS$(date +%k).* $TPATH/MIN$(date +%M).* > $TPATH/$FNAME

