# README
This is a small script that I use stream video content to friends.  I originally wrote it in BASH, although I will soon port it to Python to for Windows users.  Even so, I'll try as best as possible to debug and add features to the BASH version as it's a fairly quick and painless language for me to write in.

## Prerequisites
Install the following programs:

  - [VLC](http://www.videolan.org/index.html)
  - [oggfwd](http://v2v.cc/~j/oggfwd/)
  - [ffmpeg2theora](http://firefogg.org/nightly/)
  - [Icecast](http://www.icecast.org/)

### Mac OS X Notes
Some of these programs can be installed easily on OS X with [Macports](https://www.macports.org/). Others, such as ffmpeg2theora, can be moved directly from the ~/Downloads folder to /usr/local/bin/ or /opt/local/bin/ using `mv ffmpeg2theora.macosx /opt/local/bin/`.  

`oggfwd` can be easily compiled on OS X by changing a few parameters in the `make` file.  First, install `libshout`, `libtheora`, `libogg`, and `libvorbis` via MacPorts.  Then, simply change the prefix for the library from `/usr/` to `/opt/local/`.  This should build a binary that can be dropped in /opt/local/bin just as ffmpeg2theora.macosx was.

### Linux
I haven't directly installed the prerequisites under Linux yet, but I'm sure most can be found using `apt-cache search` or `yum search`, depending on whether you're using Ubuntu or Fedora, respectively.

## Configuration
First, set the password on line 72 to match whatever is in your icecast.xml file. Second, you may want to edit the website on line 70 to match your own. 

## Installation
```bash
chmod +x stream.sh && mv stream.sh /usr/local/bin/
```


## Features to Add
  - More robust error handling.
  - Playlist feature for ffmpeg2theora option in BASH.
  - Utilize VLC's [web interface](http://wiki.videolan.org/Documentation:Modules/http_intf).
  - Video codec choices (e.g., [Theora](http://www.theora.org/) vs. [x264](http://www.videolan.org/developers/x264.html) vs. [VP8](http://www.webmproject.org/))
