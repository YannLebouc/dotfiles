#!/usr/bin/env bash
set -euo pipefail

PROFILE="${1:-}"
if [[ -z "$PROFILE" ]]; then
  echo "Usage: $0 <desktop|thinkpad>"
  exit 1
fi

DOTFILES="${DOTFILES:-$HOME/dotfiles}"

if [[ ! -d "$DOTFILES" ]]; then
  echo "Expected dotfiles repo at: $DOTFILES"
  echo "Clone it first, then rerun."
  exit 1
fi

"$DOTFILES/scripts/install-packages.sh" "$PROFILE"
"$DOTFILES/scripts/apply-profile.sh" "$PROFILE"

echo "=== Setup complete ($PROFILE) ==="
