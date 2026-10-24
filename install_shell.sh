#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BASHRC="$HOME/.bashrc"
SOURCE_LINE="source \"$REPO_DIR/shell/bashrc\""

if [[ ! -f "$REPO_DIR/shell/bashrc" ]]; then
	echo "Shell configuration not found: $REPO_DIR/shell/bashrc" >&2
	exit 1
fi

touch "$BASHRC"
if grep -Fqx "$SOURCE_LINE" "$BASHRC"; then
	echo "Dotfiles shell configuration is already sourced by $BASHRC."
	exit 0
fi

cat >> "$BASHRC" <<EOF

# Load shared interactive shell settings from the dotfiles repo.
$SOURCE_LINE
EOF

echo "Added the dotfiles shell configuration to $BASHRC."
