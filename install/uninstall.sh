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

sudo rm -rf /usr/local/bin/orca/
sudo rm /etc/systemd/system/root-orca.service
sudo rm /etc/systemd/system/user-orca.service