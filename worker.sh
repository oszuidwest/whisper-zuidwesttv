#!/bin/bash

DB_PATH="/path/to/your/tasks.db"     # Replace with your actual path
MEDIA_PATH="/mnt/media/"             # Configure this path as needed

while true; do
    # Fetch the next 'queued' task from SQLite
    task=$(sqlite3 $DB_PATH "SELECT id, url FROM tasks WHERE status='queued' LIMIT 1")

    # Check if there's a task to process
    if [ -z "$task" ]; then
        sleep 10
        continue
    fi

    # Split the task data into ID and URL
    IFS="|" read -r id url <<< "$task"

    # Update the task status to 'downloading'
    sqlite3 $DB_PATH "UPDATE tasks SET status='downloading' WHERE id='$id'"

    # 1. Download the file
    OUTPUT_PATH="$MEDIA_PATH$id.mp4"
    if ! curl -o $OUTPUT_PATH $url; then
        sqlite3 $DB_PATH "UPDATE tasks SET status='download_failed' WHERE id='$id'"
        continue
    fi

    # Update the task status to 'converting'
    sqlite3 $DB_PATH "UPDATE tasks SET status='converting' WHERE id='$id'"

    # 2. Convert the MP4 to WAV
    WAV_PATH="${OUTPUT_PATH%.mp4}.wav"
    if ! ffmpeg -i $OUTPUT_PATH -ar 16000 -ac 1 -c:a pcm_s16le $WAV_PATH; then
        sqlite3 $DB_PATH "UPDATE tasks SET status='convert_failed' WHERE id='$id'"
        continue
    fi

    # Update the task status to 'transcribing'
    sqlite3 $DB_PATH "UPDATE tasks SET status='transcribing' WHERE id='$id'"

    # 3. Transcribe the WAV using Whisper
    TXT_PATH="$MEDIA_PATH$id.txt"
    if ! /opt/whisper/whisper.cpp-master/main \
            -m /opt/whisper/whisper.cpp-master/models/ggml-large.bin \
            -f $WAV_PATH \
            --print-colors \
            --output-vtt \
            --output-file $TXT_PATH; then
        sqlite3 $DB_PATH "UPDATE tasks SET status='transcribe_failed' WHERE id='$id'"
        continue
    fi

    # After successful transcription, update status and delete the MP4 and WAV files
    sqlite3 $DB_PATH "UPDATE tasks SET status='completed' WHERE id='$id'"
    rm $OUTPUT_PATH
    rm $WAV_PATH
done
