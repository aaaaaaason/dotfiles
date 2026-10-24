#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

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
