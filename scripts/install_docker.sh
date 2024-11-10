#!/bin/bash

# Define the Docker Desktop download link (replace with the actual link)
DOCKER_DESKTOP_URL="https://desktop.docker.com/mac/main/arm64/Docker.dmg"

# Define the download location
DOWNLOAD_PATH="$HOME/Downloads/Docker.dmg"

# Download Docker Desktop
echo "Downloading Docker Desktop..."
curl -L "$DOCKER_DESKTOP_URL" -o "$DOWNLOAD_PATH"

# Verify download success
if [ $? -ne 0 ]; then
  echo "Failed to download Docker Desktop."
  exit 1
fi
echo "Download complete."

# Mount the DMG file
echo "Mounting Docker Desktop installer..."
hdiutil attach "$DOWNLOAD_PATH" -quiet

# Install Docker Desktop
echo "Installing Docker Desktop..."
cp -R /Volumes/Docker/Docker.app /Applications

# Eject the DMG
echo "Ejecting installer..."
hdiutil detach /Volumes/Docker -quiet

# Clean up the downloaded DMG file
rm "$DOWNLOAD_PATH"
echo "Docker Desktop installed successfully."

# Start Docker Desktop
open -a Docker
echo "Docker Desktop is starting..."
