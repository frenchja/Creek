#!/bin/bash
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

#[ "$#" -eq 1 ] || echo "You must provide a movie parameter after stream.sh!" && exit 0

MOVIE=$1
HOSTNAME="$(hostname)"
clear
echo "Your hostname appears to be $(hostname)."
echo "Users will need to connect to this."
echo
read -p "Is this correct? " yn
case $yn in
	Y|y|Yes|yes)
		break ;;
	*)
		read -p "Enter your hostname: " hostname;;
esac

function vlc (){
	clear
	if "$(uname -s)" == 'Darwin':
		VLC='/Applications/VLC.app/Contents/MacOS/VLC'
		type $VLC >/dev/null 2>&1 || { 
		echo >&2 "I require VLC but it's not installed.  Aborting."; exit 1; 
	}
	else:
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
	if "$(uname -s)" == 'Darwin':
		if ! type -P ffmpeg2theora.macosx; then
			echo >&2 "Can't find ffmpeg2theora.  Aborting."
			exit 1
		else:
			FFMPEG="$(type -P ffmpeg2theora.macosx)"
		fi
	else:
		if ! type -P ffmpeg2theora; then
			echo >&2 "Can't find ffmpeg2theora.  Aborting."
			exit 1
		else:
			FFMPEG="$(type -P ffmpeg2theora)"
		fi
	fi

	if ! type -P oggfwd; then
		echo >&2 "Can't find oggfwd.  Aborting."
		exit 1
	else:
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
		--organization "http://mst3k.nofadz.com/chat/" \
		-o /dev/stdout - | \
		$OGGFWD $(hostname) 8000 password /mst3k.ogg
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