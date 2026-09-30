#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/package/src/package_managers/cargo.sh
source "$(dirname "${BASH_SOURCE[0]}")/../scripts/package/src/package_managers/cargo.sh"

cargo() {
	if [[ $# -eq 2 && $1 == install && $2 == --list ]]; then
		printf '%s' "$cargo_list"
	elif [[ $# -eq 2 && $1 == install ]]; then
		printf 'install:%s\n' "$2"
	else
		printf 'invalid cargo invocation\n'
		return 1
	fi
}

# Model xargs' default behavior: even empty input invokes the command once.
xargs() {
	if [[ "$*" != '-n1 cargo install' ]]; then
		printf 'unexpected xargs invocation\n'
		return 1
	fi
	local crate seen=0
	while IFS= read -r crate; do
		cargo install "$crate"
		seen=1
	done
	if (( ! seen )); then
		cargo install
	fi
}

output::answer() {
	printf '%s\n' "$1"
}

assert_update() {
	local expected=$1 actual
	actual=$(cargo::update_all)
	if [[ "$actual" != "$expected" ]]; then
		printf 'Expected: %s\nActual: %s\n' "$expected" "$actual" >&2
		return 1
	fi
}

cargo_list=''
assert_update 'Done'

cargo_list=$'ripgrep v14.1.0:\n    rg (bin)\nbat v0.24.0:\n    bat (bin)\n'
assert_update $'install:ripgrep\ninstall:bat\nDone'

printf 'cargo update_all: empty and nonempty lists passed\n'
