#!/usr/bin/env bash
set -euo pipefail

VCPKG_ROOT="${VCPKG_ROOT:-$HOME/.local/share/vcpkg}"

if ! command -v git >/dev/null 2>&1; then
	echo "Git is required to install vcpkg." >&2
	exit 1
fi

if [[ -e "$VCPKG_ROOT" && ! -d "$VCPKG_ROOT" ]]; then
	echo "$VCPKG_ROOT exists but is not a directory; preserving it." >&2
	exit 1
fi

if [[ -d "$VCPKG_ROOT" && ! -d "$VCPKG_ROOT/.git" ]]; then
	if [[ -z "$(find "$VCPKG_ROOT" -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
		rmdir "$VCPKG_ROOT"
	else
		echo "$VCPKG_ROOT exists but is not a vcpkg Git checkout; preserving it." >&2
		exit 1
	fi
fi

if [[ ! -e "$VCPKG_ROOT" ]]; then
	mkdir -p "$(dirname -- "$VCPKG_ROOT")"
	echo "Cloning vcpkg into $VCPKG_ROOT..."
	git clone https://github.com/microsoft/vcpkg.git "$VCPKG_ROOT"
else
	echo "vcpkg checkout already exists at $VCPKG_ROOT."
fi

if [[ ! -x "$VCPKG_ROOT/vcpkg" ]]; then
	echo "Bootstrapping vcpkg..."
	"$VCPKG_ROOT/bootstrap-vcpkg.sh"
else
	echo "vcpkg executable is already bootstrapped."
fi

echo "vcpkg is ready at $VCPKG_ROOT. Open a new shell or run: source ~/.bashrc"
