#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if ! command -v stow >/dev/null 2>&1; then
  echo "stow not installed. Run: brew install stow" >&2
  exit 1
fi

mkdir -p "$HOME/.config"

PACKAGES=(ghostty zed nvim karabiner)

for pkg in "${PACKAGES[@]}"; do
  echo "stow $pkg"
  stow --restow --target="$HOME" "$pkg"
done

echo "Done."
