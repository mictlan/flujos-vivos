#!/bin/sh
#
# this one comes from monty
# http://lists.xiph.org/pipermail/theora-dev/2010-July/004178.html

gst-launch \
       hdv1394src blocksize="4136" \
         ! queue \
         ! mpegtsdemux name=demux\
           demux. \
             ! queue \
         ! mpeg2dec \
         ! videorate \
         ! video/x-raw-yuv,framerate=12/1 \
         ! ffvideoscale \
         ! video/x-raw-yuv,width=640,height=360,pixel-aspect-ratio=1/1 \
         ! tee name=preview \
         ! ffmpegcolorspace \
             ! queue \
         ! theoraenc bitrate=200 keyframe-force=64 \
         ! queue \
         ! mux. \
            demux. \
             ! queue \
             ! mad \
             ! audioconvert \
             ! audioresample \
             ! audio/x-raw-float,channels=1,rate=16000 \
             ! queue \
             ! vorbisenc quality=0.5 \
             ! queue \
             ! mux.\
           preview. \
         ! queue\
         ! xvimagesink sync="false" \
       oggmux name=mux \
         ! queue \
         ! progressreport \
         ! shout2send ip=127.0.0.1 \
           port=8000 password=passwordhere mount=stream.ogg

