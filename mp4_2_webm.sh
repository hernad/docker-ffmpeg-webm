#!/bin/bash

MAX_CONVERSIONS=${MAX_CONVERSIONS:-1}

echo "max ffmpeg processes (MAX_CONVERSIONS) = $MAX_CONVERSIONS"

ffmpeg_convert() {
  
 ffmpeg -y -i $1 -codec:v libvpx -quality good -cpu-used 0 -b:v 500k -qmin 10 -qmax 42 -maxrate 500k -bufsize 1000k -threads 4 \
     -vf scale=-1:1080 -codec:a libvorbis -b:a 128k $2 
 echo ffmpeg return: $
 echo rm $1
}


find_mp4_files() {
   cd /data/in
   MP4_FILES=`find $INPUT_DIR -type f -name "*.MP4" -o -type f -name "*.mp4" | sed -e 's/\.\///' `
}


move_convert_mp4() {
    # FIRST_MP4=video/a.mp4, but  out/video/a.mp4 DOES NOT EXISTS

    dirname=$(dirname "$1") 
    filename=$(echo $1 | sed -e 's/.MP4$//')
    filename=$(echo $filename | sed -e 's/.mp4$//')
    CMD="touch /data/in/$1.processing"
    CMD="$CMD && ffmpeg_convert /data/in/$1 /data/in/$filename.webm"
    CMD="$CMD && rm /data/in/$1.processing"
    CMD="$CMD && rm /data/in/$1"
    CMD="$CMD && mkdir -p /data/out/$dirname"
    CMD="$CMD && rsync -avzr /data/in/$filename.webm /data/out/$filename.webm"
    CMD="$CMD && rm /data/in/$filename.webm"
    echo $CMD
    eval $CMD

}


cd /data

find_mp4_files

let cnt=0

echo $MP4_FILES
for f in $MP4_FILES 
do

  echo "mp4 file: $f" 
  if [ ! -f /data/in/$f.processing ]
  then
    move_convert_mp4 $f &
    let cnt=cnt+1
  fi

 if [ $cnt -gt $MAX_CONVERSIONS ] ; then
    exit 0
 fi

done

