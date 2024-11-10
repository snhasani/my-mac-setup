#!/bin/bash

# Step 1: Check if the app name was provided as the first argument
if [ -z "$1" ]; then
  read -p "Enter the name of the application to uninstall: " APP_NAME
else
  APP_NAME="$1"
fi

# Define paths for system-wide and user-specific applications
SYSTEM_APP_PATH="/Applications/$APP_NAME.app"
USER_APP_PATH="$HOME/Applications/$APP_NAME.app"

# Check if the application exists in either location
if [ ! -d "$SYSTEM_APP_PATH" ] && [ ! -d "$USER_APP_PATH" ]; then
  echo "Application $APP_NAME does not exist in /Applications or ~/Applications."
  exit 1
fi

# Stop the application if it's running
echo "Stopping $APP_NAME if running..."
osascript -e "quit app \"$APP_NAME\""

# Wait for a moment to ensure the app has stopped
sleep 3

# Close any network ports opened by the application
APP_PID=$(pgrep -f "$APP_NAME")
if [ -n "$APP_PID" ]; then
  echo "Closing network ports used by $APP_NAME..."
  lsof -iTCP -sTCP:LISTEN -n -P | grep "$APP_PID" | awk '{print $2}' | xargs kill -9
  echo "Network ports closed."
else
  echo "No active network ports found for $APP_NAME."
fi

# Confirm deletion from user applications folder if present
if [ -d "$USER_APP_PATH" ]; then
  read -p "Are you sure you want to uninstall $APP_NAME from your user applications folder? (yes/no): " CONFIRM_USER_DELETE
  if [ "$CONFIRM_USER_DELETE" != "yes" ]; then
    echo "Uninstallation of $APP_NAME from user folder cancelled."
  else
    echo "Removing $APP_NAME from ~/Applications..."
    rm -rf "$USER_APP_PATH"
  fi
fi

# Confirm deletion from system-wide applications folder if present
if [ -d "$SYSTEM_APP_PATH" ]; then
  read -p "Application $APP_NAME is also installed for all users. Do you want to uninstall it from /Applications as well? (yes/no): " CONFIRM_SYSTEM_DELETE
  if [ "$CONFIRM_SYSTEM_DELETE" = "yes" ]; then
    echo "Removing $APP_NAME from /Applications..."
    sudo rm -rf "$SYSTEM_APP_PATH"

    # If deleted from /Applications, proceed to remove any related system-wide files in /Library
    echo "Removing $APP_NAME files from /Library (if any)..."
    sudo rm -rf "/Library/Application Support/$APP_NAME"
    sudo rm -rf "/Library/Caches/$APP_NAME"
    sudo rm -rf "/Library/Logs/$APP_NAME"
  else
    echo "System-wide uninstallation of $APP_NAME cancelled."
  fi
fi

# Ask if user data should also be deleted
read -p "Do you want to delete all user data for $APP_NAME (Application Support, Caches, Preferences)? (yes/no): " DELETE_DATA

# Check if there is data to back up
TEMP_BACKUP_DIR=$(mktemp -d)
cp "$HOME/Library/Preferences/com.${APP_NAME// /}.plist" "$TEMP_BACKUP_DIR" 2>/dev/null
cp "$HOME/Library/Preferences/${APP_NAME}.plist" "$TEMP_BACKUP_DIR" 2>/dev/null

# If any files were copied to TEMP_BACKUP_DIR, prompt for backup
if [ "$(ls -A "$TEMP_BACKUP_DIR")" ]; then
  read -p "Do you want to back up user preferences to Dropbox before deletion? (yes/no): " BACKUP_TO_DROPBOX
  if [ "$BACKUP_TO_DROPBOX" = "yes" ]; then
    DROPBOX_DIR="$HOME/Dropbox/backup/Mac/App/${APP_NAME}"
    BACKUP_ZIP="$DROPBOX_DIR/${APP_NAME}_preferences_backup_$(date +%Y%m%d%H%M%S).zip"

    mkdir -p "$DROPBOX_DIR"
    echo "Backing up $APP_NAME preferences to $BACKUP_ZIP..."

    zip -r "$BACKUP_ZIP" "$TEMP_BACKUP_DIR"/* >/dev/null
    echo "Backup completed at $BACKUP_ZIP."
    
    # Ask for double confirmation to delete user data
    if [ "$DELETE_DATA" = "yes" ]; then
    read -p "Are you sure you want to delete all user data for $APP_NAME? This action cannot be undone. (yes/no): " DOUBLE_CONFIRM_DELETE
      if [ "$DOUBLE_CONFIRM_DELETE" != "yes" ]; then
          echo "Deletion of user data for $APP_NAME cancelled."
          exit 0
      fi
    fi

    # Delete user data if confirmed
    if [ "$DELETE_DATA" = "yes" ] && [ "$DOUBLE_CONFIRM_DELETE" = "yes" ]; then
      echo "Deleting $APP_NAME files from ~/Library..."

      rm -rf "$HOME/Library/Application Support/$APP_NAME"
      rm -rf "$HOME/Library/Application Support/${APP_NAME// /}"
      rm -rf "$HOME/Library/Caches/$APP_NAME"
      rm -rf "$HOME/Library/Caches/${APP_NAME// /}"
      rm -rf "$HOME/Library/Logs/$APP_NAME"
      rm -rf "$HOME/Library/Saved Application State/com.${APP_NAME// /}.savedState"
    fi
  fi
else
  echo "No preferences found for $APP_NAME to back up."
fi

# Clean up temporary backup directory
rm -rf "$TEMP_BACKUP_DIR"

echo "$APP_NAME has been uninstalled, and selected actions have been completed."
