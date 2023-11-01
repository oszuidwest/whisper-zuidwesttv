#!/bin/bash

URL=$1
ID=$(basename $(dirname $URL))
OUTPUT_PATH="/mnt/media/$ID.mp4"

# Try to download the file
if curl -o $OUTPUT_PATH $URL; then
    echo "success"
else
    echo "fail"
fi

