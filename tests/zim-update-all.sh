#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/package/src/package_managers/zim.sh
source "$(dirname "${BASH_SOURCE[0]}")/../scripts/package/src/package_managers/zim.sh"

zim_home=$(mktemp -d)
trap 'rm -rf "$zim_home"' EXIT

zsh() {
	printf 'zsh %s\n' "$*"
}

log::file() {
	cat
}

output::answer() {
	printf '%s\n' "$1"
}

# A zsh setup without Zim leaves ZIM_HOME unset; under `set -u` that must
# skip the update instead of aborting with an unbound variable.
unset ZIM_HOME
if zim::is_configured; then
	printf 'Expected Zim to be unconfigured without ZIM_HOME\n' >&2
	exit 1
fi

ZIM_HOME=$zim_home
if zim::is_configured; then
	printf 'Expected Zim to be unconfigured without zimfw.zsh\n' >&2
	exit 1
fi

touch "$zim_home/zimfw.zsh"
zim::is_configured

expected=$'zsh '"$zim_home"$'/zimfw.zsh upgrade\nzsh '"$zim_home"$'/zimfw.zsh update\nDone'
actual=$(zim::update_all)
if [[ "$actual" != "$expected" ]]; then
	printf 'Expected: %s\nActual: %s\n' "$expected" "$actual" >&2
	exit 1
fi

printf 'zim update_all: unset, missing and configured Zim passed\n'
