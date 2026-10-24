#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# System packages
"$REPO_DIR/install_lazyvim_deps_apt.sh"
"$REPO_DIR/install_cli_tools_apt.sh"
"$REPO_DIR/install_neovim_apt.sh"
"$REPO_DIR/install_go_apt.sh"
"$REPO_DIR/install_docker_apt.sh"
"$REPO_DIR/install_cpp_build_deps_apt.sh"

# Language runtimes
"$REPO_DIR/install_nvm.sh"
"$REPO_DIR/install_uv.sh"
"$REPO_DIR/install_jdks_sdkman.sh"
"$REPO_DIR/install_rust.sh"

# Editor and user configuration
"$REPO_DIR/install_lazyvim.sh"
"$REPO_DIR/install_tmux.sh"
"$REPO_DIR/install_codex.sh"

# Shell configuration
"$REPO_DIR/install_shell.sh"

# Desktop apps
"$REPO_DIR/install_apps_snap.sh"

# GNOME desktop tools and keyboard settings
"$REPO_DIR/install_gnome.sh"

# Traditional Chinese Pinyin input
"$REPO_DIR/install_rime_pinyin.sh"

# Fonts
"$REPO_DIR/install_ubuntu_mono_nerd_font.sh"

