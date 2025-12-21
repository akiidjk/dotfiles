#!/bin/sh

input=$1
output=$2

if [ -z "$input" ] || [ -z "$output" ]; then
    echo "Usage: $0 <input_file> <output_file>"
    exit 1
fi

if [ "${input##*.}" != "mp4" ]; then
    echo "Input file must be mp4"
    exit 1
fi

if [ "${output##*.}" != "mov" ]; then
    echo "Output file must be mov"
    exit 1
fi

ffmpeg -i ${input} -vcodec mjpeg -q:v 2 -acodec pcm_s16be -q:a 0 -f mov ${output}
