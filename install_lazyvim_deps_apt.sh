#!/usr/bin/env bash
set -euo pipefail

if ! command -v apt-get >/dev/null 2>&1; then
	echo "This script requires an apt-based Linux distribution." >&2
	exit 1
fi

PACKAGES=(build-essential ca-certificates curl fd-find fontconfig fzf git ripgrep unzip xz-utils zip)
MISSING=()
for package in "${PACKAGES[@]}"; do
	if ! dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q '^install ok installed$'; then
		MISSING+=("$package")
	fi
done

if ((${#MISSING[@]} == 0)); then
	echo "All LazyVim support packages are already installed."
else
	if [[ "${EUID}" -eq 0 ]]; then
		APT=(apt-get)
	elif command -v sudo >/dev/null 2>&1; then
		APT=(sudo apt-get)
	else
		echo "Run as root or install sudo to use this script." >&2
		exit 1
	fi
	echo "Installing missing packages: ${MISSING[*]}"
	"${APT[@]}" update
	"${APT[@]}" install -y "${MISSING[@]}"
fi

echo "Installed LazyVim support packages."
echo "Neovim itself must be >= 0.11.2 and built with LuaJIT; install a suitable build separately if needed."
