#!/bin/bash

MAX_CONVERSIONS=${MAX_CONVERSIONS:-1}

echo "max ffmpeg processes (MAX_CONVERSIONS) = $MAX_CONVERSIONS"

ffmpeg_convert() {
  
 ffmpeg -loglevel panic -y -i $1 -codec:v libvpx -quality good -cpu-used 0 -b:v 500k -qmin 10 -qmax 42 -maxrate 500k -bufsize 1000k -threads 4 \
     -vf scale=-1:1080 -codec:a libvorbis -b:a 128k $2 
 echo ffmpeg return: $
 echo rm $1
}


find_mp4_files() {
   cd /data/in

   # add ; separator
   MP4_FILES=`find $INPUT_DIR -type f -name "*.MP4" -o -type f -name "*.mp4" | sed -e 's/.*/&;/' | sed -e 's/[ ]/\\\ /g' | sed -e 's/\.\///'`

   # zagrade () -> \(\)
   MP4_FILES=`echo $MP4_FILES | sed -e 's/[(]/\\\(/g' | sed -e 's/[)]/\\\)/g'`

   echo $MP4_FILES 
}


move_convert_mp4() {
    # FIRST_MP4=video/a.mp4, but  out/video/a.mp4 DOES NOT EXISTS

    echo "ulazni fajl: $1"
    dirname=$(dirname "$1" | sed -e 's/^ //') 

    filename=$(echo "$1" | sed -e 's/.MP4$//')
    filename=$(echo "$filename" | sed -e 's/.mp4$//')
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

let cnt=1

echo $MP4_FILES
IFS=$";"
for f in $MP4_FILES 
do

  # remove ; separator, remove spaces on begin, end
  f=`echo $f | sed -e 's/;$//' | sed -e 's/^[ ]//' | sed -e 's/[ ]$//'`

  echo ">>>>>>>>> mp4 file: $f" 

  file_in_no_esc_processing=`echo /data/in/$f.processing | sed -e 's/\\\//g'`

  if [ ! -f "$file_in_no_esc_processing" ]
  then
    echo "processing ne postoji: $file_in_no_esc_processing"
    (move_convert_mp4 "$f" &)
    echo "INPUT FILE: $f"
    let cnt=cnt+1
    echo count=$cnt
  else
    echo "$file_in_no_esc_processing !"
  fi

 if [ $cnt -gt $MAX_CONVERSIONS ] ; then
    echo "max conversions limit: $MAX_CONVERSIONS reached !" 
    break
 fi

done

echo "sleep 20 sec ..."
sleep 20

while true; do

  NUM_FFMPEG=`ps aux | grep -c '[f]fmpeg'`


  if [ $NUM_FFMPEG -eq 0 ] ; then
     echo "no more ffmpeg processes ..."

     while true; do
        NUM_RSYNC=`ps aux | grep -c '[r]sync'`
        if [ $NUM_RSYNC -eq 0 ] ; then
           break
           sleep 60
        fi
     done

     echo "nothing left, bye bye ..."
     exit

  else
     echo "$NUM_FFMPEG ffmpeg conversions in process ..."
     sleep 90
  fi

done
