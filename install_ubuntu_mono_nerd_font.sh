#!/usr/bin/env bash
set -euo pipefail

FONT_DIR="$HOME/.local/share/fonts/NerdFonts/UbuntuMono"
MARKER="$FONT_DIR/.dotfiles-installed"

if [[ -f "$MARKER" ]]; then
	echo "UbuntuMono Nerd Font is already installed."
	exit 0
fi

for command_name in curl tar fc-cache; do
	if ! command -v "$command_name" >/dev/null 2>&1; then
		echo "$command_name is required. Run ./install_lazyvim_deps_apt.sh first." >&2
		exit 1
	fi
done

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TEMP_DIR"' EXIT

echo "Downloading UbuntuMono Nerd Font from the latest Nerd Fonts release..."
curl -fsSL \
	https://github.com/ryanoasis/nerd-fonts/releases/latest/download/UbuntuMono.tar.xz \
	-o "$TEMP_DIR/UbuntuMono.tar.xz"
mkdir -p "$TEMP_DIR/extracted"
tar -xJf "$TEMP_DIR/UbuntuMono.tar.xz" -C "$TEMP_DIR/extracted"

if ! find "$TEMP_DIR/extracted" -type f \( -iname '*.ttf' -o -iname '*.otf' \) -print -quit | grep -q .; then
	echo "The UbuntuMono archive did not contain any font files." >&2
	exit 1
fi

mkdir -p "$FONT_DIR"
find "$TEMP_DIR/extracted" -type f \( -iname '*.ttf' -o -iname '*.otf' \) \
	-exec install -m 0644 -t "$FONT_DIR" {} +
fc-cache -f "$FONT_DIR"
touch "$MARKER"

echo "Installed UbuntuMono Nerd Font under $FONT_DIR"
echo "Select UbuntuMono Nerd Font in your terminal's font settings."
