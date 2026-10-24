#!/usr/bin/env bash
set -euo pipefail

RUSTUP_BIN="$HOME/.cargo/bin/rustup"
BASHRC="$HOME/.bashrc"

if command -v rustup >/dev/null 2>&1 || [[ -x "$RUSTUP_BIN" ]]; then
	echo "Rustup is already installed."
else
	if ! command -v curl >/dev/null 2>&1; then
		echo "curl is required to install Rust. Run ./install_lazyvim_deps_apt.sh first." >&2
		exit 1
	fi

	INSTALLER="$(mktemp)"
	trap 'rm -f -- "$INSTALLER"' EXIT
	echo "Installing Rust with the official rustup installer..."
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o "$INSTALLER"
	sh "$INSTALLER" -y
fi

mkdir -p "$(dirname -- "$BASHRC")"
touch "$BASHRC"
if ! grep -Fq '. "$HOME/.cargo/env"' "$BASHRC"; then
	cat >> "$BASHRC" <<'EOF'

# Add rustup-managed Rust tools to PATH.
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
EOF
	echo "Added Rust's cargo bin directory to $BASHRC."
else
	echo "Rust is already configured in $BASHRC."
fi
