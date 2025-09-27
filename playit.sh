#!/bin/bash
# Playit Auto Installer - Made with ❤️ by Subhanplays
# Tested on Ubuntu/Debian systems

set -e

echo "🚀 Starting system update..."
sudo apt update -y && sudo apt upgrade -y

echo "🔧 Installing essential dependencies..."
sudo apt install -y sudo curl gpg

echo "📝 Adding Playit repository..."
curl -fsSL https://playit-cloud.github.io/ppa/key.gpg | \
  gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null

echo "📂 Adding Playit APT source list..."
echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | \
  sudo tee /etc/apt/sources.list.d/playit-cloud.list

echo "🔄 Updating package lists..."
sudo apt update -y

echo "⚡ Installing Playit..."
sudo apt install -y playit

echo "✅ Enabling and starting Playit service..."
sudo systemctl enable --now playit

echo "✨ Launching Playit setup wizard..."
playit setup

echo "🎉 Playit installation is complete!"
echo "➡️ Use 'playit status' anytime to check your tunnel status."
