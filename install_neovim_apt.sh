#!/usr/bin/env bash
set -euo pipefail

MIN_VERSION=0.11.2

nvim_is_compatible() {
	command -v nvim >/dev/null 2>&1 || return 1
	local version
	version="$(nvim --version | sed -nE '1s/^NVIM v([^ ]+).*$/\1/p')"
	[[ -n "$version" ]] || return 1
	printf '%s\n%s\n' "$MIN_VERSION" "$version" | sort -V -C || return 1
	nvim --version | grep -q 'LuaJIT'
}

if command -v nvim >/dev/null 2>&1; then
	if nvim_is_compatible; then
		echo "Neovim $MIN_VERSION or newer with LuaJIT is already installed; skipping installation."
		exit 0
	fi

	NVIM_VERSION="$(nvim --version | sed -nE '1s/^NVIM v([^ ]+).*$/\1/p' || true)"
	echo "Found Neovim ${NVIM_VERSION:-with unknown version}; skipping installation because nvim already exists." >&2
	echo "LazyVim requires Neovim $MIN_VERSION or newer built with LuaJIT. Install a suitable build separately, then rerun this script." >&2
	exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
	echo "apt-get is required to install Neovim." >&2
	exit 1
fi
if [[ "${EUID}" -eq 0 ]]; then
	APT=(apt-get)
elif command -v sudo >/dev/null 2>&1; then
	APT=(sudo apt-get)
else
	echo "Run as root or install sudo to install Neovim." >&2
	exit 1
fi

echo "Installing/upgrading Neovim from the apt repository..."
"${APT[@]}" update
"${APT[@]}" install -y neovim

if ! nvim_is_compatible; then
	echo "The installed Neovim does not meet LazyVim's requirement of version $MIN_VERSION with LuaJIT." >&2
	exit 1
fi

echo "Neovim is ready for LazyVim."
