#!/bin/sh

#change git user 

if [ -x /usr/bin/git ]

then
        git config --global user.name "radio"
        git config --global user.email radio@flujos.org
fi
