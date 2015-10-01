#!/bin/bash

docker rmi -f ffmpeg-webm
docker build -t ffmpeg-webm .

if [[ "$1" == "push" ]] ; then

   docker tag -f ffmpeg-webm $2/ffmpeg-webm
   docker push $2/ffmpeg-webm

fi
