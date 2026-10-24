#!/usr/bin/env bash
set -euo pipefail

if dpkg-query -W -f='${Status}' golang-go 2>/dev/null | grep -q '^install ok installed$'; then
	echo "Go is already installed."
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
"${APT[@]}" install -y golang-go
