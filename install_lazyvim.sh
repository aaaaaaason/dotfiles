#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$REPO_DIR/lazyvim"
TARGET_DIR="$HOME/.config/nvim"

if [[ -L "$TARGET_DIR" && "$(readlink -f -- "$TARGET_DIR")" == "$(readlink -f -- "$CONFIG_DIR")" ]]; then
	echo "LazyVim is already linked from $TARGET_DIR to $CONFIG_DIR."
	exit 0
fi

backup_path() {
	local path="$1"
	local stamp backup
	stamp="$(date +%Y%m%d-%H%M%S)"
	backup="${path}.backup-${stamp}"
	while [[ -e "$backup" || -L "$backup" ]]; do
		stamp="${stamp}-1"
		backup="${path}.backup-${stamp}"
	done
	mv -- "$path" "$backup"
	printf 'Moved existing %s to %s\n' "$path" "$backup"
}

if ! command -v git >/dev/null 2>&1; then
	echo "git is required. Run ./install_lazyvim_deps_apt.sh first." >&2
	exit 1
fi

if ! command -v nvim >/dev/null 2>&1; then
	echo "Neovim >= 0.11.2 is required. Install a recent Neovim, then rerun this script." >&2
	exit 1
fi

NVIM_VERSION="$(nvim --version | sed -nE '1s/^NVIM v([^ ]+).*$/\1/p')"
if [[ -z "$NVIM_VERSION" ]] || ! printf '%s\n%s\n' "0.11.2" "$NVIM_VERSION" | sort -V -C; then
	echo "Neovim >= 0.11.2 is required; found ${NVIM_VERSION:-unknown}." >&2
	echo "Install a recent Neovim, then rerun this script." >&2
	exit 1
fi

if ! nvim --version | grep -q 'LuaJIT'; then
	echo "Neovim must be built with LuaJIT." >&2
	exit 1
fi

if [[ ! -f "$CONFIG_DIR/init.lua" ]]; then
	TEMP_DIR="$(mktemp -d)"
	trap 'rm -rf -- "$TEMP_DIR"' EXIT

	echo "Cloning the latest LazyVim starter..."
	git clone --depth 1 https://github.com/LazyVim/starter.git "$TEMP_DIR/starter"
	rm -rf -- "$TEMP_DIR/starter/.git"

	# Keep the old partial configuration recoverable, but install a clean starter.
	if [[ -e "$CONFIG_DIR" || -L "$CONFIG_DIR" ]]; then
		backup_path "$CONFIG_DIR"
	fi
	mv -- "$TEMP_DIR/starter" "$CONFIG_DIR"
else
	echo "Using the existing repo config at $CONFIG_DIR."
fi

mkdir -p "$(dirname -- "$TARGET_DIR")"
if [[ -e "$TARGET_DIR" || -L "$TARGET_DIR" ]]; then
	backup_path "$TARGET_DIR"
fi
ln -s "$CONFIG_DIR" "$TARGET_DIR"

echo "Installed LazyVim at $CONFIG_DIR"
echo "Linked $TARGET_DIR -> $CONFIG_DIR"
echo "Start it with: nvim"
echo "After first launch, run :LazyHealth to check the setup."
