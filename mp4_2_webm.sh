#!/bin/bash

ffmpeg_convert() {
 ffmpeg -i $1 -codec:v libvpx -quality good -cpu-used 0 -b:v 500k -qmin 10 -qmax 42 -maxrate 500k -bufsize 1000k -threads 4 \
     -vf scale=-1:1080 -codec:a libvorbis -b:a 128k $2
}


first_mp4_file() {
   FIRST_MP4=`find $INPUT_DIR -type f -name "*.MP4" -o -type f -name "*.mp4" | head -1`
}


cd /data

first_mp4_file

while [ ! -z $FIRST_MP4 ]
do


 if [ ! -f out/$FIRST_MP4 ]
    # FIRST_MP4=video/a.mp4, but  out/video/a.mp4 DOES NOT EXISTS
    rsync -av $FIRST_MP4 out/$FRIST_MP4
    filename=$(basename "$FIRST_MP4")
    ffmpeg_convert out/$FIRST_MP4 out/$filename.webm 
 fi

 first_mp4_file
end

