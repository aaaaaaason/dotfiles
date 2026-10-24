#!/usr/bin/env bash
set -euo pipefail

if ! command -v snap >/dev/null 2>&1; then
	echo "Snap is required. Install and enable snapd, then rerun this script." >&2
	exit 1
fi

install_snap_app() {
	local snap_name="$1"
	local launcher="$2"
	shift 2

	if command -v "$launcher" >/dev/null 2>&1 || snap list "$snap_name" >/dev/null 2>&1; then
		echo "$snap_name is already installed."
		return 0
	fi

	if [[ "${EUID}" -eq 0 ]]; then
		snap install "$snap_name" "$@"
	elif command -v sudo >/dev/null 2>&1; then
		sudo snap install "$snap_name" "$@"
	else
		echo "Run as root or install sudo to install $snap_name." >&2
		return 1
	fi
}

install_snap_app code code --classic
install_snap_app intellij-idea intellij-idea --classic
install_snap_app spotify spotify
