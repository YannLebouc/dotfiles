#!/usr/bin/env bash
set -euo pipefail

PROFILE="${1:-}"
if [[ -z "$PROFILE" ]]; then
  echo "Usage: $0 <desktop|thinkpad>"
  exit 1
fi

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
PKG_FILE="$DOTFILES/profiles/$PROFILE/packages.txt"

if [[ ! -f "$PKG_FILE" ]]; then
  echo "Missing: $PKG_FILE"
  exit 1
fi

echo "=== System update ==="
sudo dnf update -y

echo "=== Installing rpm-fusion repositories ==="
sudo dnf install -y \
  "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
  "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

echo "=== Brave repository ==="
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo

echo "=== Packages installation ($PROFILE) ==="
# Read packages file, ignore empty lines and comments
mapfile -t PKGS < <(grep -vE '^\s*#|^\s*$' "$PKG_FILE")
sudo dnf install -y "${PKGS[@]}"

echo "=== Packages installed ==="
