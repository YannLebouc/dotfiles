#!/usr/bin/env bash
set -euo pipefail

PROFILE="${1:-}"
if [[ -z "$PROFILE" ]]; then
  echo "Usage: $0 <desktop|thinkpad>"
  exit 1
fi

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
COMMON="$DOTFILES/common"
PROF="$DOTFILES/profiles/$PROFILE"

if [[ ! -d "$COMMON" ]]; then
  echo "Missing common directory: $COMMON"
  exit 1
fi
if [[ ! -d "$PROF" ]]; then
  echo "Unknown/missing profile directory: $PROF"
  exit 1
fi

link() {
  local src="$1"
  local dst="$2"
  if [[ ! -e "$src" ]]; then
    echo "Missing source file: $src"
    exit 1
  fi
  mkdir -p "$(dirname "$dst")"
  ln -sf "$src" "$dst"
}

echo "=== Creating directories ==="
mkdir -p \
  ~/.config/{i3,i3status,tmux,alacritty,redshift,helix,rss-tui} \
  ~/.config/i3/config.d \
  ~/.local/share/applications \
  ~/.local/appimages

echo "=== Symlinks (common) ==="
link "$COMMON/i3/config"                   ~/.config/i3/config
link "$COMMON/tmux/tmux.conf"              ~/.config/tmux/tmux.conf
link "$COMMON/alacritty/alacritty.toml"    ~/.config/alacritty/alacritty.toml
link "$COMMON/helix/config.toml"           ~/.config/helix/config.toml
link "$COMMON/helix/languages.toml"        ~/.config/helix/languages.toml
link "$COMMON/redshift/redshift.conf"      ~/.config/redshift/redshift.conf
link "$COMMON/rss-tui/feeds"               ~/.config/rss-tui/feeds
link "$COMMON/applications/logseq.desktop" ~/.local/share/applications/logseq.desktop

echo "=== Symlinks (profile) ==="
link "$PROF/i3status/config"               ~/.config/i3status/config

# Optional i3 snippets
if [[ -d "$PROF/i3/config.d" ]]; then
  for f in "$PROF/i3/config.d/"*.conf; do
    [[ -e "$f" ]] || continue
    link "$f" "$HOME/.config/i3/config.d/$(basename "$f")"
  done
fi

echo "=== systemd-logind configuration (common) ==="
link "$COMMON/systemd/logind.conf" "$HOME/.cache/dotfiles-logind.conf" >/dev/null 2>&1 || true
sudo cp "$COMMON/systemd/logind.conf" /etc/systemd/logind.conf
sudo systemctl restart systemd-logind

echo "=== Apply complete ($PROFILE) ==="
