# README
Creek is a small script that I use stream video content to friends.  I originally wrote it in [BASH](https://en.wikipedia.org/wiki/Bash_%28Unix_shell%29), although I will soon port it to Python for Windows users.  Even so, I'll try as best as possible to debug and add features to the BASH version as it's a fairly quick and painless language for me to write in.

I noticed that transcoding and streaming movies to friends was a pain for the average user.  There are multiple guides for Icecast, Shoutcast, and VLC.  I'm writing the programs in this repo to help ease the burder.  However, right now they're all text/Terminal programs.  In time, I hope to lower the barrier to entry using [GUIs](https://en.wikipedia.org/wiki/Graphical_user_interface) so that the average user can broadcast copyright-free material (e.g., [Archive.org](https://archive.org/details/SciFi_Horror)) easily to friends on the fly.

## Prerequisites
Install the following programs:

  - [VLC](http://www.videolan.org/index.html)
  - [oggfwd](http://v2v.cc/~j/oggfwd/)
  - [ffmpeg2theora](http://firefogg.org/nightly/)
  - [Icecast](http://www.icecast.org/)

### Mac OS X Notes
Some of these programs can be installed easily on OS X with [Macports](https://www.macports.org/). Others, such as ffmpeg2theora, can be moved directly from the ~/Downloads folder to /usr/local/bin/ or /opt/local/bin/:
``` bash
curl -O http://firefogg.org/nightly/ffmpeg2theora.macosx &&
sudo mv ffmpeg2theora.macosx /opt/local/bin/
```  

`oggfwd` can be easily compiled on OS X by changing a few parameters in the `make` file.  First, install `libshout`, `libtheora`, `libogg`, and `libvorbis` via MacPorts:
```bash
sudo port selfupdate && sudo port install libshout2 libtheora libogg libvorbis bzr libspeex
```

 Then, simply change the prefix for the library from `/usr/` to `/opt/local/`:
```bash
bzr branch http://v2v.cc/~j/oggfwd &&
cd oggfwd &&
cc -O2 -pipe -Wall -ffast-math -fsigned-char -pthread -I/opt/local/include -L/opt/local/lib -lshout -logg -lvorbis -ltheora -lspeex -o oggfwd oggfwd.c &&
sudo mv oggfwd /opt/local/bin/
```
 This *should* build a binary that can be dropped in /opt/local/bin just as ffmpeg2theora.macosx was.

### Linux
I haven't directly installed the prerequisites under Linux yet, but I'm sure most can be found using `apt-cache search` or `yum search`, depending on whether you're using Ubuntu or Fedora, respectively.

## Installation
```bash
curl -O https://raw.github.com/frenchja/north-american-playground/master/stream.sh &&
chmod +x stream.sh &&
mv stream.sh /usr/local/bin/
```

### Configuration
First, set the password to match whatever is in your icecast.xml file. Second, you may want to edit the website to match your own. 


## Features to Add
  - More robust error handling.
  - Playlist parsing for ffmpeg2theora option in BASH.
  - Utilize VLC's [web interface](http://wiki.videolan.org/Documentation:Modules/http_intf).
  - Video codec choices (e.g., [Theora](http://www.theora.org/) vs. [x264](http://www.videolan.org/developers/x264.html) vs. [VP8](http://www.webmproject.org/)).
  - RSS feed parsing (probably in Python) (e.g., https://archive.org/services/collection-rss.php?collection=SciFi_Horror) to automate content setup.

## License Information
Any program in the north-american-playground repo is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or 
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see [http://www.gnu.org/licenses/].