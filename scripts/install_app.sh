#!/bin/bash

# Check if a URL parameter is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <URL to .dmg file>"
    exit 1
fi

# Set the URL from the first parameter and define the download location
url="$1"
encoded_url=$(echo "$url" | sed 's/ /%20/g')  # Ensure spaces in the URL are encoded as %20
dmg_name=$(basename "$url" | sed 's/%20/_/g') # Replace %20 with underscores in the filename
download_dir="$HOME/Downloads"
dmg_path="$download_dir/$dmg_name"

# Check if the dmg file already exists in the Downloads folder
if [ -f "$dmg_path" ]; then
    echo "$dmg_name already exists in $download_dir. Skipping download."
else
    echo "Downloading $dmg_name from $encoded_url to $download_dir..."
    curl -L -o "$dmg_path" "$encoded_url"
fi

# Ask the user for installation scope
echo "Do you want to install it for all users? (yes/no)"
read -r install_for_everyone

# Set the target installation directory based on the user choice
if [ "$install_for_everyone" == "yes" ]; then
    target_dir="/Applications"
elif [ "$install_for_everyone" == "no" ]; then
    target_dir="$HOME/Applications"
    mkdir -p "$target_dir"  # Ensure the user Applications directory exists
else
    echo "Invalid choice. Please enter 'yes' or 'no'."
    exit 1
fi

# Mount the dmg file and capture the output to get the exact mount point
echo "Mounting $dmg_name..."
mount_output=$(hdiutil attach "$dmg_path" -nobrowse)

if [ $? -ne 0 ]; then
    echo "Failed to mount $dmg_name"
    rm "$dmg_path"
    exit 1
fi

# Extract the mount point (look for /Volumes/ in the output)
mount_dir=$(echo "$mount_output" | grep -o '/Volumes/.*')
if [ -z "$mount_dir" ]; then
    echo "Failed to find the mount point."
    hdiutil detach "$dmg_path"
    rm "$dmg_path"
    exit 1
fi

# Find the app name inside the mounted dmg (search for any .app file)
app_name=$(find "$mount_dir" -maxdepth 1 -name "*.app" | head -n 1)
if [ -z "$app_name" ]; then
    echo "No application found inside the mounted dmg."
    hdiutil detach "$mount_dir" -quiet
    rm "$dmg_path"
    exit 1
fi

# Install the app based on the user's choice
echo "Installing $(basename "$app_name") to $target_dir..."
ditto "$app_name" "$target_dir/$(basename "$app_name")"

# Unmount the dmg
echo "Unmounting $dmg_name..."
hdiutil detach "$mount_dir"

# Clean up the downloaded dmg file
echo "Cleaning up $dmg_name from $download_dir..."
rm "$dmg_path"

echo "$app_name installed successfully in $target_dir!"
