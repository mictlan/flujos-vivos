#!/bin/bash
#
# This utility searches for available HFS+, NTFS, FAT32 and various Linux
# partitions, creates mount points for them and adds them to /etc/fstab.
#
# --
#
# (c)2008 pure:dyne team <puredyne-team@goto10.org>
# (c)2005 Dennis Kaarsemaker <dennis@ubuntu-nl.org>
# Thanks to Nalioth for suggesting, assisting with and testing the HFS+ bits
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#
# --

# Root check
if [[ $UID != 0 ]]; then
    echo 'You should run this program as root or using sudo'
    exit 1
fi

# Simple command line argument for installers
# -w: mount them with user,umask=0111
# -r: mount them with user,umask=0133,uid=1000,gid=1000
RWALL=-1;
if [[ $1 == '-w' ]]; then RWALL=1; fi
if [[ $1 == '-r' ]]; then RWALL=0; fi

if [[ $RWALL == -1 ]]; then
    echo 'By default the disks will be writable only by root and'
    cat /etc/passwd | awk -F ':|,' '/:1000:/ {print $5 " (" $1 ")"}'
    echo 'Do you want to make the disk writable by all users instead? (y/n)'
    read RESP
    if [[ $RESP == 'y' || $RESP == 'Y' ]]; then
        RWALL=1
    else
        RWALL=0
    fi
fi

if [[ $RWALL == 1 ]]; then
    OPTIONS='user,fmask=0111,dmask=0000'
    MACOPTIONS='user,file_umask=0111,dir_umask=0000'
else
    OPTIONS='user,fmask=0133,dmask=0022,uid=1000,gid=1000'
    MACOPTIONS='user,file_umask=0133,dir_umask=0022,uid=1000,gid=1000'
fi

# Now for the real work
drivesntfs=`fdisk -l | grep -i 'ntfs' | awk -F '/| ' '{print $3}'`
drivesfat=`fdisk -l | grep -i 'fat32' | awk -F '/| ' '{print $3}'`
driveshfs=`fdisk -l | grep -i 'Apple_HFS' | awk -F '/| ' '{print $3}'`
drivelinux=`fdisk -l | grep -i 'Linux' | grep -v 'swap' | awk -F '/| ' '{print $3}'`

usefuse=yes
#test -r /etc/lsb-release && source /etc/lsb-release
#if [[ "x$DISTRIB_RELEASE" == "x6.04" || "x$DISTRIB_RELEASE" > "x6.04" ]]; then
#    echo "As of Ubuntu 6.04 (Dapper Drake) there is slightly more NTFS writing support"
#    echo "through a very experimental NTFS FUSE module. Using this seems to work but"
#    echo -n "is NOT recommended. Do you want to use this? [no] "
#    read RESP
#    if [[ $RESP == 'yes' ]]; then
#        usefuse=yes
#        echo "Enabling experimental NTFS write support"
#    else
#        echo "Not enabling experimental NTFS write support"
#    fi
#fi           

donesomething='n'
for drive in $drivesntfs; do
    if [[ ! `grep $drive /etc/fstab` ]]; then
        mkdir "/media/$drive"
        if [[ $usefuse == 'yes' ]]; then
            echo "/dev/$drive /media/$drive ntfs-3g rw,$OPTIONS 0 0" >> /etc/fstab
            echo "file:///media/$drive" >> /home/radio/.gtk-bookmarks

        else
            echo "/dev/$drive /media/$drive ntfs ro,$OPTIONS 0 0" >> /etc/fstab
            echo "file:///media/$drive" >> /home/radio/.gtk-bookmarks
        fi
        echo "Added /dev/$drive as '/media/$drive'"
        donesomething='y'
    else
        echo "Ignoring /dev/$drive - already in /etc/fstab"
    fi
done
if [[ $donesomething == 'y' && $usefuse == 'no' ]]; then
    echo "NTFS drives will be mounted read-only!"
fi
    for drive in $drivesfat; do
        if [[ ! `grep $drive /etc/fstab` ]]; then
            mkdir "/media/$drive"
            echo "/dev/$drive /media/$drive vfat rw,$OPTIONS 0 0" >> /etc/fstab
            echo "file:///media/$drive" >> /home/radio/.gtk-bookmarks
            echo "Added /dev/$drive as '/media/$drive'"
            donesomething='y'
        else
            echo "Ignoring /dev/$drive - already in /etc/fstab"
        fi
    done
    for drive in $driveshfs; do
        if [[ ! `grep $drive /etc/fstab` ]]; then
            mkdir "/media/$drive"
            echo "/dev/$drive /media/$drive hfsplus rw,$MACOPTIONS 0 0" >> /etc/fstab
            echo "file:///media/$drive" >> /home/radio/.gtk-bookmarks
            echo "Added /dev/$drive as '/media/$drive'"
            donesomething='y'
        else
            echo "Ignoring /dev/$drive - already in /etc/fstab"
        fi
    done
    for drive in $drivelinux; do
        if [[ ! `grep $drive /etc/fstab` ]]; then
            mkdir "/media/$drive"
            echo "/dev/$drive /media/$drive auto defaults 0 0" >> /etc/fstab
            echo "file:///media/$drive" >> /home/radio/.gtk-bookmarks
            echo "Added /dev/$drive as '/media/$drive'"
            donesomething='y'
        else
            echo "Ignoring /dev/$drive - already in /etc/fstab"
        fi
    done
    
    if [[ $donesomething == 'y' ]]; then
        # And mount them
        echo "Mounting the partitions now..."
        mount -a
    else
        echo "No usable partitions found..."
    fi
