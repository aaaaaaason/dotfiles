#!/usr/bin/env bash
set -euo pipefail

if [[ ! -r /etc/os-release ]]; then
	echo "Cannot identify this Linux distribution." >&2
	exit 1
fi
# shellcheck disable=SC1091
source /etc/os-release
if [[ "${ID:-}" != "ubuntu" ]]; then
	echo "This installer currently supports Ubuntu only (detected: ${ID:-unknown})." >&2
	exit 1
fi

is_installed() {
	dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q '^install ok installed$'
}

DOCKER_PACKAGES=(docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin)
MISSING=()
for package in "${DOCKER_PACKAGES[@]}"; do
	if ! is_installed "$package"; then
		MISSING+=("$package")
	fi
done

if ((${#MISSING[@]} == 0)); then
	echo "Docker Engine and its CLI plugins are already installed."
	exit 0
fi

if ! is_installed docker-ce; then
	CONFLICTS=(docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc)
	FOUND_CONFLICTS=()
	for package in "${CONFLICTS[@]}"; do
		if is_installed "$package"; then
			FOUND_CONFLICTS+=("$package")
		fi
	done
	if ((${#FOUND_CONFLICTS[@]} > 0)); then
		printf 'Conflicting Docker packages are installed: %s\n' "${FOUND_CONFLICTS[*]}" >&2
		echo "Remove or migrate those packages manually before installing Docker CE." >&2
		exit 1
	fi
fi

if ! command -v curl >/dev/null 2>&1; then
	echo "curl is required to configure Docker's apt repository. Run ./install_lazyvim_deps_apt.sh first." >&2
	exit 1
fi

if [[ "${EUID}" -eq 0 ]]; then
	ROOT=()
elif command -v sudo >/dev/null 2>&1; then
	ROOT=(sudo)
else
	echo "Run as root or install sudo to use this script." >&2
	exit 1
fi

KEYRING=/etc/apt/keyrings/docker.asc
SOURCE_FILE=/etc/apt/sources.list.d/docker.sources
KEY_TMP=""
"${ROOT[@]}" install -m 0755 -d /etc/apt/keyrings
if [[ ! -s "$KEYRING" ]]; then
	KEY_TMP="$(mktemp)"
	trap 'rm -f -- "$KEY_TMP"' EXIT
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o "$KEY_TMP"
	"${ROOT[@]}" install -m 0644 "$KEY_TMP" "$KEYRING"
fi

ARCH="$(dpkg --print-architecture)"
CODENAME="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"
if [[ -z "$CODENAME" ]]; then
	echo "Could not determine the Ubuntu release codename." >&2
	exit 1
fi

SOURCE_TMP="$(mktemp)"
trap 'rm -f -- "${KEY_TMP:-}" "$SOURCE_TMP"' EXIT
cat > "$SOURCE_TMP" <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $CODENAME
Components: stable
Architectures: $ARCH
Signed-By: $KEYRING
EOF
if ! cmp -s "$SOURCE_TMP" "$SOURCE_FILE" 2>/dev/null; then
	"${ROOT[@]}" install -m 0644 "$SOURCE_TMP" "$SOURCE_FILE"
fi

"${ROOT[@]}" apt-get update
"${ROOT[@]}" apt-get install -y "${MISSING[@]}"
echo "Installed Docker Engine and its CLI plugins."
echo "Use sudo for Docker commands unless you have separately configured Docker group access."
