#!/bin/bash


MAX_CONVERSIONS=${MAX_CONVERSIONS:-1}

videos_dir=${1:-$(pwd)/videos}

echo $videos_dir

[ ! -d $videos_dir/in ] && echo "$videos_dir/in does not exists !"  && exit 1

docker rm -f ffmpeg-mp4-webm

docker run \
   --name ffmpeg-mp4-webm \
   -e MAX_CONVERSIONS=$MAX_CONVERSIONS \
   -v $videos_dir:/data \
   -ti \
   hernad/ffmpeg-webm /bin/bash
