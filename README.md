# docker ffmpeg-webm


## build

    ./build.sh


build and push to hernad/ffmpeg-webm

    ./build.sh push hernad

## Run


Prerequisites: mp4 files in $(pwd)/videos/in/


    MAX_CONVERSIONS=5 ./run_conversion_videos.sh
    

    ./run_conversion_videos.sh /data/my_videos


Debug:

    MAX_CONVERSIONS=5 ./run_conversion_videos.sh $(pwd)/videos /bin/bash


