#!/bin/bash
set -e

SERVICE_USER="_gmail_proxy"

# Check and copy secrets.toml if present
if [ -f /app/secrets.toml ]; then
    echo "Found /app/secrets.toml, copying to /etc/gmail-proxy/"
    cp /app/secrets.toml /etc/gmail-proxy/
fi

# Check and copy client_secret.json if present
if [ -f /app/client_secret.json ]; then
    echo "Found /app/client_secret.json, copying to /etc/gmail-proxy/"
    cp /app/client_secret.json /etc/gmail-proxy/
fi

# 1. Install service if not already installed
if ! id "$SERVICE_USER" &>/dev/null; then
    echo "Creating service user $SERVICE_USER"
    useradd -r -s /bin/false "$SERVICE_USER"
fi

if [ ! -f /etc/systemd/system/gmail-proxy.service ]; then
    echo "Installing gmail-proxy systemd service..."
    /app/gmail-proxy install --service-user "$SERVICE_USER" --openclaw-user "$SERVICE_USER"
    echo "Running gmail-proxy setup (OAuth/skill/webhook)..."
    /app/gmail-proxy setup --service-user "$SERVICE_USER" --openclaw-user "$SERVICE_USER" --client-json /etc/gmail-proxy/client_secret.json
    SLEEP 60
fi

# 2. Start service (systemd or fallback)
if command -v systemctl &>/dev/null; then
    echo "Enabling and starting gmail-proxy via systemd..."
    systemctl enable --now gmail-proxy
    systemctl status gmail-proxy
#else
#    echo "Starting gmail-proxy in foreground (no systemd)..."
#    exec gmail-proxy serve
fi