#!/bin/bash

echo "Stopping Docker Desktop..."
osascript -e 'quit app "Docker"'

# Wait a few seconds to ensure Docker has stopped
sleep 5

echo "Removing Docker Desktop application..."
rm -rf /Applications/Docker.app

echo "Removing Docker binaries..."
rm -f /usr/local/bin/docker
rm -f /usr/local/bin/docker-compose
rm -f /usr/local/bin/docker-credential-*
rm -f /usr/local/bin/docker-machine

echo "Removing Docker settings and configurations..."
rm -rf $HOME/.docker
rm -rf $HOME/Library/Containers/com.docker.docker
rm -rf $HOME/Library/Application\ Support/Docker
rm -rf $HOME/Library/Group\ Containers/group.com.docker
rm -rf $HOME/Library/Preferences/com.docker.docker.plist
rm -rf $HOME/Library/Preferences/com.electron.docker-frontend.plist
rm -rf $HOME/Library/Saved\ Application\ State/com.electron.docker-frontend.savedState

echo "Removing Docker Virtual Machines..."
rm -rf $HOME/Library/Containers/com.docker.helper
rm -rf $HOME/Library/Group\ Containers/group.com.docker

echo "Removing Docker networking files..."
sudo rm -rf /var/run/docker.sock
sudo rm -rf /var/tmp/com.docker.vmnetd.sock

echo "Docker Desktop has been completely uninstalled."
