#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SDKMAN_DIR="$HOME/.sdkman"

"$REPO_DIR/install_sdkman.sh"

if [[ ! -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
	echo "SDKMAN installation did not produce sdkman-init.sh." >&2
	exit 1
fi
if ! command -v curl >/dev/null 2>&1; then
	echo "curl is required to find Temurin releases." >&2
	exit 1
fi

case "$(uname -m)" in
	x86_64|amd64) SDKMAN_PLATFORM=linuxx64 ;;
	aarch64|arm64) SDKMAN_PLATFORM=linuxarm64 ;;
	armv7l) SDKMAN_PLATFORM=linuxarm32hf ;;
	*) echo "Unsupported SDKMAN platform: $(uname -m)" >&2; exit 1 ;;
esac

install_temurin_jdk() {
	local major="$1"
	local installed_version=""
	local candidate
	local version_list latest_version has_current
	local installed_versions=()

	for candidate in "$SDKMAN_DIR"/candidates/java/"$major".*-tem; do
		[[ -d "$candidate" ]] || continue
		installed_versions+=("${candidate##*/}")
	done
	if ((${#installed_versions[@]} > 0)); then
		installed_version="$(printf '%s\n' "${installed_versions[@]}" | sort -V | tail -n 1)"
		echo "Temurin JDK $installed_version is already installed."
		if [[ ! -e "$SDKMAN_DIR/candidates/java/current" && ! -L "$SDKMAN_DIR/candidates/java/current" ]]; then
			SDKMAN_DIR="$SDKMAN_DIR" JAVA_VERSION="$installed_version" bash -c \
				'source "$SDKMAN_DIR/bin/sdkman-init.sh" && sdk default java "$JAVA_VERSION"'
		fi
		return 0
	fi

	version_list="$(curl -fsSL "https://api.sdkman.io/2/candidates/java/${SDKMAN_PLATFORM}/versions/all")"
	latest_version="$(printf '%s' "$version_list" | tr ',' '\n' | grep -E "^${major}\\.[0-9]+(\\.[0-9]+)*(\\+[a-z0-9]+(\\.[a-z0-9]+)*)?-tem$" | sort -V | tail -n 1 || true)"
	if [[ -z "$latest_version" ]]; then
		echo "Could not find a Temurin JDK $major release in the SDKMAN catalog." >&2
		return 1
	fi

	echo "Installing Temurin JDK $latest_version with SDKMAN..."
	if [[ -e "$SDKMAN_DIR/candidates/java/current" || -L "$SDKMAN_DIR/candidates/java/current" ]]; then
		has_current=1
	else
		has_current=0
	fi
	if ((has_current)); then
		# Keep the user's existing default JDK when adding another version.
		printf 'n\n' | SDKMAN_DIR="$SDKMAN_DIR" JAVA_VERSION="$latest_version" bash -c \
			'source "$SDKMAN_DIR/bin/sdkman-init.sh" && sdk install java "$JAVA_VERSION"'
	else
		# The first installed JDK becomes the default; install 21 before 17 below.
		printf 'y\n' | SDKMAN_DIR="$SDKMAN_DIR" JAVA_VERSION="$latest_version" bash -c \
			'source "$SDKMAN_DIR/bin/sdkman-init.sh" && sdk install java "$JAVA_VERSION"'
	fi
}

# Keep Java 21 as the default on a fresh setup, then add Java 17 without
# replacing an existing SDKMAN default. Both versions remain switchable via sdk.
install_temurin_jdk 21
install_temurin_jdk 17
