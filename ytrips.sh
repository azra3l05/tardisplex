#!/bin/bash

# Path to your commands file
file="/home/azra3l/codebase/tardisplex/yt_rips.txt"

# Path to the cookies.txt file (exported from your browser after logging in)
cookies_file="/home/azra3l/codebase/tardisplex/cookies.txt"

# Output directory
output_dir="/mnt/unionfs/downloads/youtubedl"

# Temporary file to store remaining commands
temp_file=$(mktemp)

# Loop through each line in the commands file
while IFS= read -r line
do
    # Modify the format to enforce 1080p and specify the output directory
    modified_command=$(echo "$line" | sed 's|-f.*|-f "bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[height<=1080][ext=mp4]/best"|' )
    modified_command="$modified_command --cookies \"$cookies_file\" -o \"$output_dir/%(title)s.%(ext)s\""
    
    # Execute the modified command
    echo "Running: $modified_command"
    if eval "$modified_command"; then
        echo "Download succeeded for: $line"
    else
        # If the command fails, save the line to the temp file
        echo "$line" >> "$temp_file"
        echo "Download failed for: $line. Keeping it in the list."
    fi
done < "$file"

# Replace the original file with the temporary file
mv "$temp_file" "$file"

echo "Processing complete. Remaining URLs are saved back to $file."
