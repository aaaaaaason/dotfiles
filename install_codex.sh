#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v codex >/dev/null 2>&1; then
	if ! command -v curl >/dev/null 2>&1; then
		echo "curl is required to install Codex CLI. Run ./install_lazyvim_deps_apt.sh first." >&2
		exit 1
	fi

	INSTALLER="$(mktemp)"
	trap 'rm -f -- "$INSTALLER"' EXIT
	echo "Installing Codex CLI with the official OpenAI installer..."
	curl -fsSL https://chatgpt.com/codex/install.sh -o "$INSTALLER"
	sh "$INSTALLER"
else
	echo "Codex CLI is already installed: $(codex --version)"
fi

if [[ -x "$HOME/.local/bin/codex" ]]; then
	PATH="$HOME/.local/bin:$PATH"
	export PATH
fi
if ! command -v codex >/dev/null 2>&1; then
	echo "Codex CLI installation finished, but 'codex' is not on PATH. Start a new shell or add ~/.local/bin to PATH." >&2
	exit 1
fi

install_link() {
	local source_path="$1"
	local target_path="$2"
	mkdir -p "$(dirname -- "$target_path")"
	if [[ -L "$target_path" && "$(readlink -- "$target_path")" == "$source_path" ]]; then
		echo "Already linked: $target_path"
		return 0
	fi
	if [[ -e "$target_path" || -L "$target_path" ]]; then
		echo "Keeping existing path: $target_path" >&2
		return 0
	fi
	ln -s "$source_path" "$target_path"
	echo "Linked $target_path -> $source_path"
}

install_link "$REPO_DIR/codex/AGENTS.md" "$HOME/.codex/AGENTS.md"
install_link "$REPO_DIR/codex/skills" "$HOME/.agents/skills"
