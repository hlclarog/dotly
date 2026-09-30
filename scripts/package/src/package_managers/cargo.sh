# shellcheck shell=bash
cargo::update_all() {
	cargo install --list | grep -E '^[a-z0-9_-]+ v[0-9.]+:$' | cut -f1 -d' ' | while IFS= read -r crate; do
		cargo install "$crate"
	done
	output::answer "Done"
}
