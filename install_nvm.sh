#!/usr/bin/env bash
set -euo pipefail

NVM_DIR="${XDG_CONFIG_HOME:+$XDG_CONFIG_HOME/nvm}"
NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
INSTALLER_VERSION="v0.40.8"
BASHRC="$HOME/.bashrc"

if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
	if ! command -v curl >/dev/null 2>&1; then
		echo "curl is required to install nvm. Run ./install_lazyvim_deps_apt.sh first." >&2
		exit 1
	fi

	INSTALLER="$(mktemp)"
	trap 'rm -f -- "$INSTALLER"' EXIT
	echo "Installing nvm $INSTALLER_VERSION..."
	curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${INSTALLER_VERSION}/install.sh" -o "$INSTALLER"
	PROFILE=/dev/null NVM_DIR="$NVM_DIR" bash "$INSTALLER"
else
	echo "nvm is already installed at $NVM_DIR."
fi

# Install the latest available LTS release and make it the default for new shells.
NVM_DIR="$NVM_DIR" bash -c '
set -euo pipefail
source "$NVM_DIR/nvm.sh"
nvm install --lts
LTS_VERSION="$(nvm version "lts/*")"
if [[ "$LTS_VERSION" == "N/A" ]]; then
	echo "Could not resolve the installed Node.js LTS version." >&2
	exit 1
fi
nvm alias default "$LTS_VERSION"
nvm use default
'

mkdir -p "$(dirname -- "$BASHRC")"
touch "$BASHRC"
if ! grep -Fq '$NVM_DIR/nvm.sh' "$BASHRC"; then
	cat >> "$BASHRC" <<'EOF'

# Load nvm (managed by the dotfiles installer).
export NVM_DIR="${NVM_DIR:-$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")}"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
EOF
	echo "Added nvm loading to $BASHRC."
else
	echo "nvm is already configured in $BASHRC."
fi
