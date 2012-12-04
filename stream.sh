#!/bin/bash
#
# Install List:
#   ffmpeg2theora:  http://firefogg.org/nightly/
#   icecast:  http://www.icecast.org/download.php
#   oggfwd:  http://v2v.cc/~j/oggfwd/
#
# Copyright 2012 - 2013.
#
# stream.sh is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# stream.sh is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with stream.sh.  If not, see <http://www.gnu.org/licenses/>.

set -e
MOVIE=$1
HOSTNAME="$(hostname)"
IP="$(curl http://automation.whatismyip.com/n09230945.asp)"
exec 2>~/Desktop/"$(date +%Y-%m-%d)".log

# Doesn't work...
# [ "$#" -eq 1 ] || { echo "You must provide a movie parameter after stream.sh!" 1>&2 && exit 0 }

clear
echo "Your hostname appears to be $HOSTNAME."
echo "Users will need to connect to this."
echo ""
echo -n "Is this correct? "
read yn

case $yn in
    Y|y|Yes|yes|YES)
        break ;;
    *)
        echo -n "Enter your hostname or IP: "
        read HOSTNAME ;;
esac

clear
echo "What website do you want to include in the Metadata?"
echo "This could be an IRC channel or forum..."
echo -n ": "
read WEBSITE

function icepass (){
    clear
    echo "Please enter the password for the Icecast server"
    echo -n ": "
    read PASSWORD
    export PASSWORD

    clear
    echo "Where is Icecast setup?"
    echo "1)  This computer."
    echo "2)  Another server."
    echo 
    echo -n ": "
    read iceserver
    case $iceserver in
        1)
            ;;
        2)
            echo "What's the hostname or IP address?"
            echo
            echo -n ": "
            read HOSTNAME
            ;;
        *)
            echo  "That's not a valid option!"
            read -p
            icepass
            ;;
    esac
}

function vlc (){
    clear
    if "$(uname -s)" == 'Darwin'; then
        VLC='/Applications/VLC.app/Contents/MacOS/VLC'
        type $VLC >/dev/null 2>&1 || { 
        echo "I require VLC but it's not installed.  Aborting." 1>&2; exit 0; 
    }
    else
        VLC="$(type -P vlc)"
    
    fi

    VLC "$MOVIE" \
        -I \
        --sout="#transcode{vcodec=x264{bframes=5},vb=256,scale=0.67,acodec=aac,ab=32,channels=1,audio-sync=1,fps=15,}:standard{access=http,mux=ts,dst='http://$HOSTNAME:8000'}"
    vlcid=$!
    wait
    kill $vlcid
    pkill vlc

    exit 1
}

function ffmpeg (){
    icepass
   
    if ! type -P icecast; then
            echo >&2 "Can't find icecast.  Aborting."
            exit 0
    else
            ICECAST="$(type -P icecast)"
            export ICECAST
     fi
    
    $ICECAST -b -c /opt/local/etc/icecast.xml &
    icepid=$!
    
    unamestr=`uname`
    if [[ "$unamestr" == 'Darwin' ]]; then
        if ! type -P ffmpeg2theora.macosx; then
            echo >&2 "Can't find ffmpeg2theora.  Aborting."
            exit 0
        else
            FFMPEG="$(type -P ffmpeg2theora.macosx)"
            export FFMPEG
        fi
    else
        if ! type -P ffmpeg2theora; then
            echo >&2 "Can't find ffmpeg2theora.  Aborting."
            exit 0
        else
            FFMPEG="$(type -P ffmpeg2theora)"
            export FFMPEG
        fi
    fi

    if ! type -P oggfwd; then
        echo >&2 "Can't find oggfwd.  Aborting."
        exit 0
    else
        OGGFWD="$(type -P oggfwd)"
        export OGGFWD
    fi

    clear
    echo "================================="
    echo "Playing $(basename "$MOVIE") at:"
    echo "http://$IP:8000/movie.ogg"
    echo
    echo "Press Ctrl+c to exit at any time."
    echo "================================="
    echo

    $FFMPEG "$MOVIE" \
        -a 0 \
        -v 6 \
        --max_size "640x480" \
        -c 1 \
        -F 15 \
        --no-skeleton \
        --subtitle-types=all \
        --subtitles-language "en_US" \
        --artist "$(users)" \
        --title "$(basename "$MOVIE")" \
        --date "$(date +%Y-%m-%d)" \
        --organization "$WEBSITE" \
        -o /dev/stdout - | \
        $OGGFWD "$HOSTNAME" 8000 "$PASSWORD" /movie.ogg
    oggpid=$!
    
    wait
    kill $icepid
    pkill icecast
    
    exit 1
}

menu (){
    clear
    echo "There are two ways of streaming:"
    echo "1)  Using Icecast, ffmpeg2theora, and oggfwd."
    echo "2)  Using VLC."
    echo 
    echo "Q)  Quit."
    echo 
    echo -n "Which would you like to try? "
    read s

    case "$s" in
        1 )
            ffmpeg ;;
        2 )
            echo -n "Not implemented yet.  Choose 1!"
            read
            menu ;;
        Q|q|Quit|quit|exit )
            exit 1 ;;
        * )
            echo "Invalid choice!"
            menu ;;
    esac

    wait 
    exit 1
}

menu