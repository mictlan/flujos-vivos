#!/bin/sh

# if darkice is not running start it
pgrep darkice || /usr/bin/darkice &> /dev/null 2>&1
pgrep jack.plumbing || /usr/bin/jack.plumbing &> /dev/null 2>&1

