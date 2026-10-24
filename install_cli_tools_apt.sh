#!/usr/bin/env bash
set -euo pipefail

if ! command -v apt-get >/dev/null 2>&1; then
	echo "This script requires an apt-based Linux distribution." >&2
	exit 1
fi

# Handy command-line tools for everyday development and system maintenance.
# `bat` is invoked as `batcat` on Ubuntu; `eza` is an enhanced `ls` alternative.
PACKAGES=(bat eza jq ncdu shellcheck tealdeer tree zoxide)
MISSING=()
for package in "${PACKAGES[@]}"; do
	if ! dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q '^install ok installed$'; then
		MISSING+=("$package")
	fi
done

if ((${#MISSING[@]} == 0)); then
	echo "All recommended command-line tools are already installed."
else
	if [[ "${EUID}" -eq 0 ]]; then
		APT=(apt-get)
	elif command -v sudo >/dev/null 2>&1; then
		APT=(sudo apt-get)
	else
		echo "Run as root or install sudo to use this script." >&2
		exit 1
	fi
	echo "Installing missing command-line tools: ${MISSING[*]}"
	"${APT[@]}" update
	"${APT[@]}" install -y "${MISSING[@]}"
fi

echo "Installed recommended command-line tools. Use 'tldr --update' once to fetch the command examples."
