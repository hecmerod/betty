# GitHub Actions Self-Hosted Runner Setup

This guide explains how to install a GitHub Actions runner on your Raspberry Pi 5.

## Prerequisites

- Raspberry Pi 5 with Raspberry Pi OS (64-bit)
- Node.js 20+ installed
- PM2 installed globally

## Installation Steps

### 1. Create a Runner on GitHub

1. Go to your repository: `https://github.com/YOUR_USERNAME/betty`
2. Navigate to **Settings** → **Actions** → **Runners**
3. Click **New self-hosted runner**
4. Select **Linux** and **ARM64**

### 2. Install on Raspberry Pi

SSH into your Pi and run these commands (GitHub will show you the exact commands with your token):

```bash
# Create a folder for the runner
mkdir -p ~/actions-runner && cd ~/actions-runner

# Download the latest runner package (ARM64)
curl -o actions-runner-linux-arm64-2.321.0.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.321.0/actions-runner-linux-arm64-2.321.0.tar.gz

# Extract the installer
tar xzf ./actions-runner-linux-arm64-2.321.0.tar.gz

# Configure the runner (use the token from GitHub)
./config.sh --url https://github.com/YOUR_USERNAME/betty --token YOUR_TOKEN

# Install as a service (runs on boot)
sudo ./svc.sh install
sudo ./svc.sh start
```

### 3. Verify Installation

```bash
# Check service status
sudo ./svc.sh status

# View logs
journalctl -u actions.runner.YOUR_USERNAME-betty.rpi-runner.service -f
```

## Alternative: Docker Installation

If you prefer Docker:

```bash
docker run -d --restart always \
  --name github-runner \
  -e RUNNER_NAME="rpi-runner" \
  -e RUNNER_TOKEN="YOUR_TOKEN" \
  -e RUNNER_REPOSITORY_URL="https://github.com/YOUR_USERNAME/betty" \
  -e RUNNER_LABELS="self-hosted,Linux,ARM64" \
  -v /home/pi/betty:/home/pi/betty \
  -v /var/run/docker.sock:/var/run/docker.sock \
  myoung34/docker-github-actions-runner:latest
```

## How It Works

1. **Push to `main`** → GitHub Actions triggers
2. **Test job** runs on GitHub's servers (free)
3. **Deploy job** runs on your Pi (self-hosted runner)
4. PM2 restarts the server with the new build

## Troubleshooting

### Runner not picking up jobs

```bash
sudo ./svc.sh stop
sudo ./svc.sh start
```

### Check runner logs

```bash
cat ~/actions-runner/_diag/Runner_*.log | tail -50
```

### Runner offline in GitHub

Ensure the service is running and has internet access.
