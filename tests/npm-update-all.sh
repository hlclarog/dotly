#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=scripts/package/src/package_managers/npm.sh
source "$(dirname "${BASH_SOURCE[0]}")/../scripts/package/src/package_managers/npm.sh"

calls=$(mktemp)
trap 'rm -f "$calls"' EXIT

# A Node manager such as fnm installs npm under the user's home, so sudo
# neither has npm on its PATH nor is needed to write the global prefix.
sudo() {
	printf 'sudo %s\n' "$*" >>"$calls"
	return 1
}

npm() {
	case "$1" in
	--location=global) printf '%s' "$npm_outdated" ;;
	view) printf '%s\n' "$2@1.0.0" '' "summary of $2" "https://example.test/$2" ;;
	install) printf 'npm %s\n' "$*" >>"$calls" ;;
	*)
		printf 'invalid npm invocation\n'
		return 1
		;;
	esac
}

output::write() { :; }
output::empty_line() { :; }
output::answer() { printf '%s\n' "$1" >>"$calls"; }
log::file() { cat >/dev/null; }

assert_calls() {
	local expected=$1 actual
	: >"$calls"
	npm::update_all || printf 'update_all exited %s\n' "$?" >>"$calls"
	actual=$(cat "$calls")
	if [[ "$actual" != "$expected" ]]; then
		printf 'Expected: %s\nActual: %s\n' "$expected" "$actual" >&2
		return 1
	fi
}

npm_outdated=''
assert_calls 'Already up-to-date'

npm_outdated=$'Package  Current  Wanted  Latest  Location\ncorepack  0.34.0  0.34.1  0.34.1  global\nnpm  11.6.0  11.6.2  11.6.2  global\n'
assert_calls $'npm install --location=global corepack\nnpm install --location=global npm'

printf 'npm update_all: updates without sudo passed\n'
