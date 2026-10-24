#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

PACKAGES=(
	fcitx5
	fcitx5-config-qt
	fcitx5-frontend-gtk2
	fcitx5-frontend-gtk3
	fcitx5-frontend-qt5
	fcitx5-rime
	im-config
	rime-data-luna-pinyin
)
MISSING=()
for package in "${PACKAGES[@]}"; do
	if ! dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q '^install ok installed$'; then
		MISSING+=("$package")
	fi
done

if ((${#MISSING[@]} > 0)); then
	if ! command -v apt-get >/dev/null 2>&1; then
		echo "This script requires an apt-based Linux distribution." >&2
		exit 1
	fi
	if [[ "${EUID}" -eq 0 ]]; then
		APT=(apt-get)
	elif command -v sudo >/dev/null 2>&1; then
		APT=(sudo apt-get)
	else
		echo "Run as root or install sudo to install Fcitx5 and Rime." >&2
		exit 1
	fi
	echo "Installing missing Fcitx5 and Rime packages: ${MISSING[*]}"
	"${APT[@]}" update
	"${APT[@]}" install -y "${MISSING[@]}"
else
	echo "Fcitx5, Rime, and Luna Pinyin data are already installed."
fi

CONFIG_DIR="$HOME/.config/fcitx5"
PROFILE="$CONFIG_DIR/profile"
mkdir -p "$CONFIG_DIR"
if [[ ! -e "$PROFILE" ]]; then
	cat > "$PROFILE" <<'EOF'
[Groups/0]
Name=Default
Default Layout=us
DefaultIM=keyboard-us

[Groups/0/Items/0]
Name=keyboard-us
Layout=

[Groups/0/Items/1]
Name=rime
Layout=

[GroupOrder]
0=Default
EOF
	echo "Created an Fcitx5 profile with English and Rime input methods."
elif grep -Eq '^Name=rime[[:space:]]*$' "$PROFILE"; then
	echo "Rime is already listed in the Fcitx5 profile."
elif grep -Fxq '[Groups/0]' "$PROFILE"; then
	ITEM_INDEX=0
	while grep -Fxq "[Groups/0/Items/$ITEM_INDEX]" "$PROFILE"; do
		ITEM_INDEX=$((ITEM_INDEX + 1))
	done
	cat >> "$PROFILE" <<EOF

[Groups/0/Items/$ITEM_INDEX]
Name=rime
Layout=
EOF
	echo "Added Rime to the existing Fcitx5 default group."
else
	echo "Preserved $PROFILE because its group layout is unfamiliar. Add Rime with fcitx5-config-qt." >&2
	exit 1
fi

RIME_DIR="$HOME/.local/share/fcitx5/rime"
RIME_DEFAULT="$RIME_DIR/default.custom.yaml"
mkdir -p "$RIME_DIR"
if [[ -L "$RIME_DEFAULT" && "$(readlink -f -- "$RIME_DEFAULT")" == "$(readlink -f -- "$REPO_DIR/rime/default.custom.yaml")" ]]; then
	echo "Rime schema configuration is already linked from the dotfiles repo."
elif [[ ! -e "$RIME_DEFAULT" && ! -L "$RIME_DEFAULT" ]]; then
	ln -s "$REPO_DIR/rime/default.custom.yaml" "$RIME_DEFAULT"
	echo "Linked the Taiwan Traditional Luna Pinyin schema configuration."
elif grep -Fq 'schema: luna_pinyin_tw' "$RIME_DEFAULT"; then
	echo "Rime is already configured to use the Taiwan Traditional Luna Pinyin schema."
else
	echo "Preserved existing $RIME_DEFAULT. Merge in $REPO_DIR/rime/default.custom.yaml to enable Taiwan Traditional Pinyin." >&2
	exit 1
fi

if command -v im-config >/dev/null 2>&1; then
	im-config -n fcitx5
	echo "Selected Fcitx5 with im-config; log out and back in to activate it."
else
	echo "im-config is unavailable; install it and select Fcitx5 as the input method framework." >&2
	exit 1
fi
