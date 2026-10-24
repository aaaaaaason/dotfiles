#!/usr/bin/env bash
set -euo pipefail

PACKAGES=(gnome-tweaks gnome-shell-extension-manager solaar)
MISSING=()
for package in "${PACKAGES[@]}"; do
	if ! dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q '^install ok installed$'; then
		MISSING+=("$package")
	fi
done

if ((${#MISSING[@]} > 0)); then
	if ! command -v apt-get >/dev/null 2>&1; then
		echo "This script requires an apt-based Linux distribution." >&2
		exit 1
	fi
	if [[ "${EUID}" -eq 0 ]]; then
		APT=(apt-get)
	elif command -v sudo >/dev/null 2>&1; then
		APT=(sudo apt-get)
	else
		echo "Run as root or install sudo to install GNOME tools." >&2
		exit 1
	fi
	echo "Installing missing GNOME packages: ${MISSING[*]}"
	"${APT[@]}" update
	"${APT[@]}" install -y "${MISSING[@]}"
else
	echo "GNOME Tweaks, Extension Manager, and Solaar are already installed."
fi

SCHEMA=org.gnome.desktop.input-sources
KEY=xkb-options
if ! command -v gsettings >/dev/null 2>&1 || [[ "$(gsettings writable "$SCHEMA" "$KEY")" != true ]]; then
	echo "GNOME settings are unavailable or read-only in this session; skipping Caps Lock remap."
	exit 0
fi

CURRENT_OPTIONS="$(gsettings get "$SCHEMA" "$KEY")"
case "$CURRENT_OPTIONS" in
	*"'ctrl:nocaps'"*)
		echo "Caps Lock is already mapped to Control."
		exit 0
		;;
	"@as []"|"[]")
		NEW_OPTIONS="['ctrl:nocaps']"
		;;
	\[*\])
		NEW_OPTIONS="${CURRENT_OPTIONS%]}"
		NEW_OPTIONS+=", 'ctrl:nocaps']"
		;;
	*)
		echo "Could not parse existing GNOME XKB options: $CURRENT_OPTIONS" >&2
		exit 1
		;;
esac

gsettings set "$SCHEMA" "$KEY" "$NEW_OPTIONS"
echo "Mapped Caps Lock to Control in GNOME keyboard settings."
