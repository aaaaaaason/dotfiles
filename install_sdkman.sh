#!/usr/bin/env bash
set -euo pipefail

SDKMAN_DIR="$HOME/.sdkman"
BASHRC="$HOME/.bashrc"

if [[ ! -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
	if ! command -v curl >/dev/null 2>&1; then
		echo "curl is required to install SDKMAN. Run ./install_lazyvim_deps_apt.sh first." >&2
		exit 1
	fi
	INSTALLER="$(mktemp)"
	trap 'rm -f -- "$INSTALLER"' EXIT
	echo "Installing SDKMAN..."
	curl -fsSL 'https://get.sdkman.io?rcupdate=false' -o "$INSTALLER"
	SDKMAN_DIR="$SDKMAN_DIR" bash "$INSTALLER"
else
	echo "SDKMAN is already installed at $SDKMAN_DIR."
fi

touch "$BASHRC"
if ! grep -Fq '# Initialize SDKMAN (managed by the dotfiles installer).' "$BASHRC"; then
	cat >> "$BASHRC" <<'EOF'

# Initialize SDKMAN (managed by the dotfiles installer).
export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
EOF
	echo "Added SDKMAN initialization to $BASHRC."
else
	echo "SDKMAN is already configured in $BASHRC."
fi
