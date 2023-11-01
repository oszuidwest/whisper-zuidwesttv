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
    sqlite3 $DB_PATH "UPDATE tasks SET status='downloading' WHERE id=$id"

    # Download the file
    if ./download.sh "$url"; then
        # Continue with the rest of the process if download was successful
        mp4_path="/mnt/media/$(basename $(dirname $url)).mp4"
        
        # Convert the file
        sqlite3 $DB_PATH "UPDATE tasks SET status='converting' WHERE id=$id"
        if ./convert.sh "$mp4_path"; then
            # Transcribe the file if conversion was successful
            wav_path="${mp4_path%.mp4}.wav"
            sqlite3 $DB_PATH "UPDATE tasks SET status='transcribing' WHERE id=$id"
            if ./transcribe.sh "$wav_path"; then
                # Mark task as 'completed'
                sqlite3 $DB_PATH "UPDATE tasks SET status='completed' WHERE id=$id"
            else
                # If any script fails, update the task status to 'failed'
                sqlite3 $DB_PATH "UPDATE tasks SET status='failed' WHERE id=$id"
            fi
        else
            sqlite3 $DB_PATH "UPDATE tasks SET status='failed' WHERE id=$id"
        fi
    else
        sqlite3 $DB_PATH "UPDATE tasks SET status='failed' WHERE id=$id"
    fi

    sleep 1
done

