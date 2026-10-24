#!/usr/bin/env bash
set -euo pipefail

UV_INSTALL_DIR="$HOME/.local/bin"
BASHRC="$HOME/.bashrc"

mkdir -p "$UV_INSTALL_DIR"
mkdir -p "$(dirname -- "$BASHRC")"
touch "$BASHRC"

if ! grep -Fq '# uv executable path (managed by the dotfiles installer)' "$BASHRC"; then
	cat >> "$BASHRC" <<'EOF'

# uv executable path (managed by the dotfiles installer).
case ":$PATH:" in
	*":$HOME/.local/bin:"*) ;;
	*) export PATH="$HOME/.local/bin:$PATH" ;;
esac
EOF
	echo "Added $UV_INSTALL_DIR to PATH in $BASHRC."
fi

if command -v uv >/dev/null 2>&1 || [[ -x "$UV_INSTALL_DIR/uv" ]]; then
	echo "uv is already installed."
else
	if ! command -v curl >/dev/null 2>&1; then
		echo "curl is required to install uv. Run ./install_lazyvim_deps_apt.sh first." >&2
		exit 1
	fi

	INSTALLER="$(mktemp)"
	trap 'rm -f -- "$INSTALLER"' EXIT
	echo "Installing uv..."
	curl -fsSL https://astral.sh/uv/install.sh -o "$INSTALLER"
	UV_INSTALL_DIR="$UV_INSTALL_DIR" UV_NO_MODIFY_PATH=1 sh "$INSTALLER"
fi

if [[ -x "$UV_INSTALL_DIR/uv" ]]; then
	UV_BIN="$UV_INSTALL_DIR/uv"
else
	UV_BIN="$(command -v uv)"
fi

# Run outside any project so a local .python-version cannot change this to a
# project-specific interpreter. uv verifies/installs its latest managed Python.
PYTHON_INSTALL_DIR="$(mktemp -d)"
trap 'rm -rf -- "$PYTHON_INSTALL_DIR"' EXIT
echo "Ensuring uv's latest managed Python is installed..."
(cd "$PYTHON_INSTALL_DIR" && "$UV_BIN" python install)
