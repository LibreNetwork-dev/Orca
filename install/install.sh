#!/bin/bash

set -e

echo "[*] Installing services..."

# idk if tihs works but it makes me feel good
if systemctl list-units --full -all | grep -q '^root-orca.service'; then
    echo "Stopping root-orca.service..."
    sudo systemctl kill root-orac.service || echo "Failed to kill root-orca.service, but moving on."
else
    echo "root-orca.service not found. Skipping."
fi
if systemctl list-units --full -all | grep -q '^user-orca.service'; then
    echo "Stopping user-orca.service..."
    sudo systemctl kill user-orca.service || echo "Failed to kill user-orca.service, but moving on."
else
    echo "user-orca.service not found. Skipping."
fi


sudo mkdir -p /usr/local/bin/orca/
sudo cp -r ../dist/* /usr/local/bin/orca/

REAL_USER=$(logname)
USER_HOME=$(eval echo "~$REAL_USER")

echo "[+] Installing root-orca..."
sudo cp root-orca.service /etc/systemd/system/
sudo chmod 644 /etc/systemd/system/root-orca.service

echo "[+] Installing user-orca.service for $REAL_USER..."
USER_SYSTEMD_DIR="$USER_HOME/.config/systemd/user"
mkdir -p "$USER_SYSTEMD_DIR"
cp user-orca.service "$USER_SYSTEMD_DIR/"
chmod 644 "$USER_SYSTEMD_DIR/user-orca.service"
chown "$REAL_USER":"$REAL_USER" "$USER_SYSTEMD_DIR/user-orca.service"

echo "[*] Reloading systemd..."
sudo systemctl daemon-reload
sudo -u "$REAL_USER" systemctl --user daemon-reload

echo "[*] Enabling and starting services..."

sudo systemctl enable --now root-orca.service
sudo -u "$REAL_USER" systemctl --user enable --now user-orca.service

echo "[✓] Done! Use these to check status:"
echo "    sudo systemctl status root-orca.service"
echo "    systemctl --user status user-orca.service"


