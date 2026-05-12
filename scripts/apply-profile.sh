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
  ~/.config/{i3,i3status,tmux,alacritty,redshift,helix,rss-tui,private} \
  ~/.config/i3/config.d \
  ~/.local/bin \
  ~/vpn/azur \
  ~/.local/share/applications \
  ~/.config/zathura

echo "=== AppImages setup ==="

mkdir -p ~/.local/appimages
chmod +x ~/.local/appimages/*.AppImage 2>/dev/null || true

echo "=== Symlinks (common) ==="
link "$COMMON/i3/config"                ~/.config/i3/config
link "$COMMON/tmux/tmux.conf"           ~/.config/tmux/tmux.conf
link "$COMMON/alacritty/alacritty.toml" ~/.config/alacritty/alacritty.toml
link "$COMMON/redshift/redshift.conf"   ~/.config/redshift/redshift.conf
link "$COMMON/rss-tui/feeds"            ~/.config/rss-tui/feeds
link "$COMMON/helix/config.toml"        ~/.config/helix/config.toml
link "$COMMON/helix/languages.toml"     ~/.config/helix/languages.toml
link "$COMMON/applications/obsidian.desktop" ~/.local/share/applications/obsidian.desktop
link "$COMMON/zathura/zathurarc" ~/.config/zathura/zathurarc

echo "=== Symlinks (profile) ==="
link "$PROF/i3status/config" ~/.config/i3status/config

if [[ -d "$PROF/i3/config.d" ]]; then
  for f in "$PROF/i3/config.d/"*.conf; do
    [[ -e "$f" ]] || continue
    link "$f" "$HOME/.config/i3/config.d/$(basename "$f")"
  done
fi

echo "=== Symlinks (common bin scripts) ==="
if [[ -d "$COMMON/bin" ]]; then
  for f in "$COMMON/bin/"*; do
    [[ -e "$f" ]] || continue
    chmod +x "$f"
    link "$f" "$HOME/.local/bin/$(basename "$f")"
  done
fi

echo "=== systemd-logind configuration (common) ==="
sudo cp "$COMMON/systemd/logind.conf" /etc/systemd/logind.conf
sudo systemctl restart systemd-logind

echo "=== Private config bootstrap ==="
chmod 700 "$HOME/.config/private"

if [[ ! -f "$HOME/.config/private/work.env" ]]; then
  if [[ -f "$COMMON/templates/work.env.template" ]]; then
    cp "$COMMON/templates/work.env.template" "$HOME/.config/private/work.env"
    chmod 600 "$HOME/.config/private/work.env"
    echo "Created ~/.config/private/work.env from template"
    echo "Please edit it with your real values."
  else
    echo "Missing template: $COMMON/templates/work.env.template"
  fi
fi

echo "=== Ensuring Go bin is in PATH ==="

GO_PATH_LINE='export PATH="$HOME/go/bin:$PATH"'

if ! grep -Fq "$GO_PATH_LINE" "$HOME/.bashrc"; then
  echo '' >> "$HOME/.bashrc"
  echo '# dotfiles-go-path' >> "$HOME/.bashrc"
  echo "$GO_PATH_LINE" >> "$HOME/.bashrc"
  echo "Added ~/go/bin to PATH in ~/.bashrc"
fi

echo "=== Apply complete ($PROFILE) ==="
