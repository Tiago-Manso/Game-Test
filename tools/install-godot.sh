#!/usr/bin/env bash
# Install a headless-capable Godot binary (standard build, GDScript) and gdtoolkit.
# Used by cloud sessions / CI so the loop can import, lint and test the project.
# Usage: tools/install-godot.sh            (version from .godot-version)
#        GODOT_VERSION=4.5.1-stable tools/install-godot.sh
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
version="${GODOT_VERSION:-$(tr -d '[:space:]' < "$root/.godot-version")}"
dest="${GODOT_INSTALL_DIR:-$HOME/.local/bin}"

if command -v godot >/dev/null && godot --version 2>/dev/null | grep -q "^${version%-stable}"; then
  echo "godot $version already installed"
else
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  url="https://github.com/godotengine/godot/releases/download/${version}/Godot_v${version}_linux.x86_64.zip"
  echo "downloading $url"
  curl -fsSL "$url" -o "$tmp/godot.zip"
  unzip -q "$tmp/godot.zip" -d "$tmp"
  mkdir -p "$dest"
  install -m 755 "$tmp/Godot_v${version}_linux.x86_64" "$dest/godot"
  echo "installed godot $version to $dest/godot"
fi

if ! command -v gdlint >/dev/null; then
  pip install --quiet "gdtoolkit==4.*"
fi
