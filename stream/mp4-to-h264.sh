#!/bin/sh

INPUT=$1
OUTPUT=$2

ffmpeg -i $INPUT -an -vcodec copy -bsf h264_mp4toannexb -f h264 $OUTPUT

echo "finish ..."

