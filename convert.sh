#!/bin/bash

INPUT_PATH=$1
OUTPUT_PATH="${INPUT_PATH%.mp4}.wav"

# Convert MP4 to WAV
if ffmpeg -i $INPUT_PATH -ac 1 $OUTPUT_PATH; then
    echo "success"
else
    echo "fail"
fi

