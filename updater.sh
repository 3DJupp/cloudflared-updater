#!/bin/bash
# Variables
PACKAGE_NAME="cloudflared"
ARCHITECTURE="amd64"  # Change this according to the architecture (e.g., arm64, amd64)
DEB_PACKAGE_NAME="cloudflared-linux-${ARCHITECTURE}.deb"
LATEST_RELEASE_URL="https://api.github.com/repos/cloudflare/cloudflared/releases/latest"
LOG_FILE="/root/upgrade_cloudflared.log"
TEMP_DEB="$(mktemp)"
GITHUB_TOKEN="***Enter your Token***" # Insert your GitHub token here

# Extend PATH / might prevent issues with arm64/amd64
export PATH="/usr/local/sbin:/usr/sbin:/sbin:$PATH"

log_message() {
    echo "$(date '+%d.%m.%Y %H:%M:%S') - $1" >> $LOG_FILE
}

cleanup() {
    # Delete temporary file and restart the service
    rm -f $TEMP_DEB
    systemctl restart cloudflared.service
}

# Check if jq is installed, otherwise install it
if ! command -v jq &> /dev/null; then
    log_message "jq is not installed. Attempting to install jq."
    apt-get update && apt-get install -y jq
    if ! command -v jq &> /dev/null; then
        log_message "Failed to install jq. Please install jq manually."
        cleanup
        exit 1
    else
        log_message "jq installed successfully."
    fi
fi

# Download the latest release data
#log_message "Downloading release data from GitHub."
RELEASE_DATA=$(curl -s -H "Authorization: token $GITHUB_TOKEN" $LATEST_RELEASE_URL)

if [ -z "$RELEASE_DATA" ]; then
    log_message "Error: No data received from the GitHub API."
    cleanup
    exit 1
fi

#log_message "Extracting download URL for $DEB_PACKAGE_NAME."
DOWNLOAD_URL=$(echo "$RELEASE_DATA" | jq -r ".assets[] | select(.name == \"$DEB_PACKAGE_NAME\") | .browser_download_url")

if [ -z "$DOWNLOAD_URL" ]; then
    log_message "Error: Could not find the download URL for $DEB_PACKAGE_NAME."
    log_message "Received release data: $RELEASE_DATA"
    cleanup
    exit 1
fi

# Get the local version
if dpkg -l | grep -q "^ii  $PACKAGE_NAME "; then
  LOCAL_VERSION=$(dpkg -s $PACKAGE_NAME | grep '^Version:' | awk '{print $2}')
else
  LOCAL_VERSION="not installed"
fi

# Get the latest version from GitHub
LATEST_VERSION=$(echo "$RELEASE_DATA" | jq -r '.tag_name' | sed 's/^v//')
if [ "$LOCAL_VERSION" != "$LATEST_VERSION" ]; then
  log_message "Update required. Old version: $LOCAL_VERSION, New version: $LATEST_VERSION."
  
  # Download the new version
  log_message "Downloading new version from $DOWNLOAD_URL"
  curl -s -L --output $TEMP_DEB $DOWNLOAD_URL

  if [ ! -f "$TEMP_DEB" ]; then
    log_message "Error: Downloaded file not found."
    cleanup
    exit 1
  fi

  # Stop the service if it is active
  if systemctl is-active --quiet cloudflared.service; then
    log_message "cloudflared.service is active. Stopping the service."
    systemctl stop cloudflared.service
  fi

  # Uninstall the old version if it exists
  if dpkg -l | grep -q "^ii  $PACKAGE_NAME "; then
    log_message "Uninstalling old version of $PACKAGE_NAME."
    dpkg -r $PACKAGE_NAME
  fi

  # Error handling: If installation fails, restart the service.
  ERROR_OUTPUT=$(dpkg -i $TEMP_DEB 2>&1)
  if [ $? -ne 0 ]; then
      log_message "Error installing the new version: $ERROR_OUTPUT"
      cleanup
      exit 1
  else
      log_message "Update successfully completed. New version: $LATEST_VERSION."
      cleanup
      exit 0
  fi
else
  log_message "No updates available. Current version: $LOCAL_VERSION."
fi
