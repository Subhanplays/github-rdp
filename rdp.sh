#!/usr/bin/env bash
# install-xrdp.sh
# Usage: sudo ./install-xrdp.sh <username>
set -euo pipefail

TARGET_USER="${1:-ubuntu}"

# Update and install packages
apt update
DEBIAN_FRONTEND=noninteractive apt -y install xrdp xfce4 xfce4-terminal dbus-x11 xorgxrdp

# Create user if doesn't exist
if ! id -u "$TARGET_USER" >/dev/null 2>&1; then
  useradd -m -s /bin/bash "$TARGET_USER"
  echo "User $TARGET_USER created."
  echo "Set password for $TARGET_USER:"
  passwd "$TARGET_USER"
fi

# Ensure user has a desktop session file
XRDP_SESSION_FILE="/home/${TARGET_USER}/.xsession"
if [ ! -f "$XRDP_SESSION_FILE" ]; then
  cat > "$XRDP_SESSION_FILE" <<'EOF'
#!/bin/bash
# start xfce session for xrdp
startxfce4
EOF
  chown "$TARGET_USER":"$TARGET_USER" "$XRDP_SESSION_FILE"
  chmod 755 "$XRDP_SESSION_FILE"
fi

# Configure xrdp to use /etc/ssl/private/ssl-cert-snakeoil.key permission for ssl-cert group
adduser xrdp ssl-cert || true

# Optional: configure lightdm vs default. XFCE + xrdp usually works with .xsession above.

# Enable and restart xrdp
systemctl enable xrdp
systemctl restart xrdp

# Open firewall port 3389 (if using ufw)
if command -v ufw >/dev/null 2>&1; then
  ufw allow 3389/tcp
  ufw reload || true
  echo "ufw configured to allow 3389/tcp"
else
  echo "ufw not installed — ensure port 3389 is allowed in your network/firewall."
fi

# Print connection info
IP="$(hostname -I | awk '{print $1}' || true)"
echo "Done. Connect with RDP client to: ${IP:-<your-server-ip>}:3389"
echo "Login with user: $TARGET_USER and the password you set."
