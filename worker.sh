#!/bin/bash

DB_PATH="/path/to/your/tasks.db"

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
    OUTPUT_PATH="/mnt/media/$id.mp4"
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

    # 3. Transcribe the WAV (This is a placeholder, replace with OpenAI's Whisper)
    TXT_PATH="${WAV_PATH%.wav}.txt"
    echo $WAV_PATH > $TXT_PATH

    # Replace the above 'echo' with your transcription method.
    # After transcription, check if it was successful
    if [ $? -eq 0 ]; then
        sqlite3 $DB_PATH "UPDATE tasks SET status='completed' WHERE id='$id'"
        
        # Delete the MP4 and WAV files after successful transcription
        rm $OUTPUT_PATH
        rm $WAV_PATH
    else
        sqlite3 $DB_PATH "UPDATE tasks SET status='transcribe_failed' WHERE id='$id'"
        continue
    fi
done
