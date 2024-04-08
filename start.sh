#!/bin/bash

# Source and destination directories
SOURCE="/home/ian/wormhole/send/"
SSH_LOGIN="ian@ct311-infile"
REMOTE_DIR="/home/ian/wormhole/receive"

# File transfer limit
BANDWIDTH="2500" # in KBytes/s

# Check if the destination server is reachable
if ssh -q -o ConnectTimeout=5 "$SSH_LOGIN" exit; then
    echo "Destination server is reachable. Proceeding with file transfer."
else
    echo "Error: Destination server is not reachable."
    exit 1
fi

# Destination in rsync format
DESTINATION="$SSH_LOGIN:$REMOTE_DIR"

# Infinite loop to continuously watch the directory for changes
while true; do

    # Check if there are files in the source directory
    while [ -n "$(find "$SOURCE" -maxdepth 1 -type f)" ]; do
        echo Files detected
        # Perform rsync transfer
        rsync -av --exclude=".*" --bwlimit="$BANDWIDTH" --remove-source-files "$SOURCE" "$DESTINATION"
    done

    # Use inotifywait to wait for file creation or modification
    inotifywait -r -e close_write --format '%w%f' "$SOURCE"
done
