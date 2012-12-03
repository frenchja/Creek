#!/bin/bash
#
# Install List:
# 	ffmpeg2theora:  http://firefogg.org/nightly/
# 	icecast:  http://www.icecast.org/download.php
# 	oggfwd:  http://v2v.cc/~j/oggfwd/
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
exec 2>~/Desktop/"$(date +%Y-%m-%d)".log

# Doesn't work...
# [ "$#" -eq 1 ] || { echo "You must provide a movie parameter after stream.sh!" 1>&2 && exit 0 }

clear
echo "Your hostname appears to be $(hostname)."
echo "Users will need to connect to this."
echo ""
read -p "Is this correct? " yn
case $yn in
	Y|y|Yes|yes)
		break ;;
	*)
		read -p "Enter your hostname: " HOSTNAME;;
esac

function icepass (){
	clear
	echo "Please enter the password for the Icecast server"
	echo ""
	read -p ": " PASSWORD
	export PASSWORD
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
	clear
	echo "================================="
	echo "Playing $(basename "$MOVIE") at:"
	echo "http://$HOSTNAME:8000/mst3k.ogg"
	echo
	echo "Press Ctrl+c to exit at any time."
	echo "================================="
	echo
	ICECAST="$(type -P icecast)"
	$ICECAST -b -c /opt/local/etc/icecast.xml &
	icepid=$!
	icepass
	
	if "$(uname -s)" == 'Darwin'; then
		if ! type -P ffmpeg2theora.macosx; then
			echo >&2 "Can't find ffmpeg2theora.  Aborting."
			exit 0
		else
			FFMPEG="$(type -P ffmpeg2theora.macosx)"
		fi
	else
		if ! type -P ffmpeg2theora; then
			echo >&2 "Can't find ffmpeg2theora.  Aborting."
			exit 0
		else
			FFMPEG="$(type -P ffmpeg2theora)"
		fi
	fi

	if ! type -P oggfwd; then
		echo >&2 "Can't find oggfwd.  Aborting."
		exit 0
	else
		OGGFWD="$(type -P oggfwd)"
	fi

	"$FFMPEG" "$MOVIE" \
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
		--organization "http://website.com" \
		-o /dev/stdout - | \
		$OGGFWD "$HOSTNAME" 8000 "$PASSWORD" /mst3k.ogg
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
	read -p "Which would you like to try? " s

	case "$s" in
		1 )
			ffmpeg ;;
		2 )
			read -p "Not implemented yet.  Choose 1!"
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