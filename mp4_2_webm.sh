#!/bin/bash

MAX_CONVERSIONS=${MAX_CONVERSIONS:-1}

ffmpeg_convert() {
 ffmpeg -y -i $1 -codec:v libvpx -quality good -cpu-used 0 -b:v 500k -qmin 10 -qmax 42 -maxrate 500k -bufsize 1000k -threads 4 \
     -vf scale=-1:1080 -codec:a libvorbis -b:a 128k $2
}


first_mp4_file() {
   cd /data/in
   FIRST_MP4=`find $INPUT_DIR -type f -name "*.MP4" -o -type f -name "*.mp4" | head -1`
}


move_convert_mp4() {
    # FIRST_MP4=video/a.mp4, but  out/video/a.mp4 DOES NOT EXISTS
    filename=$(echo $FIRST_MP4 | sed -e 's/.MP4$//')
    filename=$(echo $filename | sed -e 's/.mp4$//')

    echo $filename
    rsync -av /data/in/$FIRST_MP4 /data/out/$FRIST_MP4 && rm /data/in/$FIRST_MP4 && ffmpeg_convert /data/out/$FIRST_MP4 /data/out/$filename.webm && rm /data/out/$FIRST_MP4 
}


cd /data

first_mp4_file

let cnt=0
while [ ! -z $FIRST_MP4 ]
do

 if [ ! -f out/$FIRST_MP4 ]
 then
    move_convert_mp4 $FIRST_MP4 &
    let cnt=cnt+1
 fi

 if [ $cnt -gt $MAX_CONVERSIONS ] ; then
    exit 0
 fi

 first_mp4_file
done

