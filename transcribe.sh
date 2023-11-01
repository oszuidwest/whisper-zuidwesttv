#!/bin/bash

INPUT_PATH=$1
OUTPUT_PATH="${INPUT_PATH%.wav}.txt"

# Transcribe WAV to TEXT (This is a placeholder, replace with actual transcription command)
# For the sake of testing, we're echoing the file path.
echo $INPUT_PATH > $OUTPUT_PATH

if [ $? -eq 0 ]; then  # Check the exit code of the last command (echo in this case)
    echo "success"
else
    echo "fail"
fi

