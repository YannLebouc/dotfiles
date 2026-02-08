#!/usr/bin/env bash
set -e

# -----------------------------
# 1️⃣ Mise à jour du système
# -----------------------------
echo "=== System update ==="
sudo dnf update -y

echo "=== Installing rpm-fusion repositories==="

sudo dnf install \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm

sudo dnf install \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# -----------------------------
# 2 Installation des packages
# -----------------------------
echo "=== Packages installation ==="
# i3 / WM
sudo dnf install -y rofi feh xset
# Terminal / Shell
sudo dnf install -y alacritty tmux
# Dev
sudo dnf install -y git helix gcc-c++ clang lldb cmake make golang ripgrep fzf delve
# Audio
sudo dnf install -y pavucontrol pipewire-utils fuse-libs
# Network
sudo dnf install -y network-manager-applet
# UX
sudo dnf install -y redshift scrot
# Apps
sudo dnf install -y discord
# Utils
sudo dnf install -y htop unzip wget curl

# -----------------------------
# 3️⃣ Création des dossiers
# -----------------------------
echo "=== Création des dossiers de configuration ==="
mkdir -p ~/.config/i3
mkdir -p ~/.config/i3status
mkdir -p ~/.config/tmux
mkdir -p ~/.config/alacritty
mkdir -p ~/.config/redshift
mkdir -p ~/.config/helix
mkdir -p ~/.local/appimages
mkdir -p ~/.local/share/applications

# -----------------------------
# 4️⃣ Symlinks creation
# -----------------------------
DOTFILES=~/dotfiles

echo "=== Symlinks creation ==="
ln -sf $DOTFILES/i3/config ~/.config/i3/config
ln -sf $DOTFILES/i3status/config ~/.config/i3status/config
ln -sf $DOTFILES/tmux/tmux.conf ~/.config/tmux/tmux.conf
ln -sf $DOTFILES/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml
ln -sf $DOTFILES/redshift/redshift.conf ~/.config/redshift/redshift.conf
ln -sf $DOTFILES/helix/config.toml ~/.config/helix/config.toml
ln -sf $DOTFILES/applications/logseq.desktop ~/.local/share/applications/logseq.desktop

echo "=== Setup complete ! ==="
