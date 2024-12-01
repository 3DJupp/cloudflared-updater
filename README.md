# Cloudflared Updater Script

This repository contains `updater.sh`, a bash script designed to automate the update process for the Cloudflare Tunnel (`cloudflared`) service on Linux-based systems.

## Features

- Automatically fetches the latest release information for `cloudflared` from GitHub.
- Downloads and installs the latest `.deb` package based on your system architecture (`amd64`, `arm64`, etc.).
- Logs most actions and errors to a specified log file.
- Restarts the `cloudflared` service after the update process.
- Fully customizable for different architectures, log file locations, and other settings.

## Requirements

- **GitHub Personal Access Token** (optional): Used to increase the API rate limit.
- **Dependencies**: `jq` (automatically installed by the script if not present).

## Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/3DJupp/cloudflared-updater.git
cd cloudflared-updater
```

### Step 2: Configure the Script

Open `updater.sh` and modify the following variables as needed:

1. **Architecture**:  
   Change the architecture if necessary (`amd64`, `arm64`, etc.):
   ```bash
   ARCHITECTURE="amd64"
   ```

2. **GitHub Token** (optional):  
   Add your GitHub token for higher API rate limits:
   ```bash
   GITHUB_TOKEN="***Enter your Token***"
   ```

3. **Log File Location**:  
   Update the log file location if desired:
   ```bash
   LOG_FILE="/root/upgrade_cloudflared.log"
   ```

### Step 3: Run the Script

Make the script executable and run it:

```bash
chmod +x updater.sh
sudo ./updater.sh
```

## Customization

The script allows customization of key variables:

- **Architecture**: Set the `ARCHITECTURE` variable to match your system (e.g., `amd64`, `arm64`).
- **GitHub Token**: Set the `GITHUB_TOKEN` for increased API rate limits.
- **Log File**: Modify the `LOG_FILE` path to change where the logs are stored.
- **Service Name**: Adapt the script to manage different services by changing `cloudflared.service`.

## How It Works

1. **Checks for `jq`**:  
   If `jq` is not installed, the script installs it using `apt-get`.

2. **Fetches Latest Release Data**:  
   Queries the GitHub API to retrieve the latest release information for `cloudflared`.

3. **Compares Installed Version**:  
   The script checks the currently installed version against the latest available version.

4. **Updates `cloudflared`**:  
   - If a new version is available, the script downloads and installs it.
   - Stops and restarts the `cloudflared` service after installation.

5. **Logging**:  
   Most actions, including successful updates, errors, and important information, are logged in the file specified by the `LOG_FILE` variable.

## Example Log Output

```text
01.12.2024 10:15:23 - jq is not installed. Attempting to install jq.
01.12.2024 10:15:30 - jq installed successfully.
01.12.2024 10:15:32 - Update required. Old version: 2023.11.0, New version: 2023.12.0.
01.12.2024 10:15:35 - Downloading new version from https://github.com/cloudflare/cloudflared/releases/download/2023.12.0/cloudflared-linux-amd64.deb
01.12.2024 10:15:40 - Update successfully completed. New version: 2023.12.0.
```

## Troubleshooting

- **GitHub API Rate Limits**:  
  If the script fails due to rate limits, provide a GitHub token in the `GITHUB_TOKEN` variable.

- **Permission Issues**:  
  Ensure the script is run with sufficient permissions to manage system services and files.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
