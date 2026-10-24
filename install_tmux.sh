#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TPM_DIR="$HOME/.tmux/plugins/tpm"
TMUX_CONF_DIR="$HOME/.config/tmux"
TMUX_CONF_TARGET="$TMUX_CONF_DIR/tmux.conf"

if ! dpkg-query -W -f='${Status}' tmux 2>/dev/null | grep -q '^install ok installed$'; then
	if ! command -v apt-get >/dev/null 2>&1; then
		echo "apt-get is required to install tmux." >&2
		exit 1
	fi
	if [[ "${EUID}" -eq 0 ]]; then
		APT=(apt-get)
	elif command -v sudo >/dev/null 2>&1; then
		APT=(sudo apt-get)
	else
		echo "Run as root or install sudo to install tmux." >&2
		exit 1
	fi
	"${APT[@]}" update
	"${APT[@]}" install -y tmux
else
	echo "tmux is already installed."
fi

if [[ -d "$TPM_DIR/.git" ]] && git -C "$TPM_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	echo "TPM is already installed."
elif [[ -e "$TPM_DIR" || -L "$TPM_DIR" ]]; then
	echo "TPM path exists but is not a Git checkout; preserving it: $TPM_DIR" >&2
	exit 1
else
	if ! command -v git >/dev/null 2>&1; then
		echo "git is required to install tmux plugin manager (TPM)." >&2
		exit 1
	fi
	echo "Installing tmux plugin manager (TPM)..."
	mkdir -p "$(dirname -- "$TPM_DIR")"
	TEMP_DIR="$(mktemp -d)"
	trap 'rm -rf -- "$TEMP_DIR"' EXIT
	git clone --depth 1 https://github.com/tmux-plugins/tpm "$TEMP_DIR/tpm"
	mv -- "$TEMP_DIR/tpm" "$TPM_DIR"
fi

mkdir -p "$TMUX_CONF_DIR"
if [[ -L "$TMUX_CONF_TARGET" && "$(readlink -- "$TMUX_CONF_TARGET")" == "$REPO_DIR/tmux/tmux.conf" ]]; then
	echo "tmux.conf is already linked."
elif [[ -e "$TMUX_CONF_TARGET" || -L "$TMUX_CONF_TARGET" ]]; then
	echo "Keeping existing tmux config: $TMUX_CONF_TARGET" >&2
else
	ln -s "$REPO_DIR/tmux/tmux.conf" "$TMUX_CONF_TARGET"
	echo "Linked $TMUX_CONF_TARGET -> $REPO_DIR/tmux/tmux.conf"
fi
