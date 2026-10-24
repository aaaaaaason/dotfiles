#!/usr/bin/env bash
set -euo pipefail

PACKAGES=(build-essential cmake clang-format clang-tidy clangd)
MISSING=()
for package in "${PACKAGES[@]}"; do
	if ! dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q '^install ok installed$'; then
		MISSING+=("$package")
	fi
done

if ((${#MISSING[@]} == 0)); then
	echo "C/C++ build tools, clang-format, clang-tidy, and clangd are already installed."
	exit 0
fi

if [[ "${EUID}" -eq 0 ]]; then
	APT=(apt-get)
elif command -v sudo >/dev/null 2>&1; then
	APT=(sudo apt-get)
else
	echo "Run as root or install sudo to use this script." >&2
	exit 1
fi

"${APT[@]}" update
"${APT[@]}" install -y "${MISSING[@]}"
