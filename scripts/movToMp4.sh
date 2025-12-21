#!/bin/sh

input=$1
output=$2

if [ -z $input ] || [ -z $output ]; then
    echo "Usage: $0 <input.mov> <output.mp4>"
    exit 1
fi

# check extension

if [ "${input##*.}" != "mov" ]; then
    echo "Input file must be a .mov file"
    exit 1
fi

if [ "${output##*.}" != "mp4" ]; then
    echo "Output file must be a .mp4 file"
    exit 1
fi

ffmpeg -i ${input} -vcodec h264 -acodec aac ${output}
