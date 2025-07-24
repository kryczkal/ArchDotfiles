#!/usr/bin/env bash
# Add useful aliases to shell configuration files.
# MODULE_DEPENDENCIES: install_rust_cli_utilities
set -euo pipefail
IFS=$'\n\t'

source "$(dirname "$0")/../lib/utils.bash"

aliases=(
	'alias .="$TERM --working-directory=$(pwd) & disown"'
	'alias ls="lsd"'
	'alias l="lsd -lah"'
	'alias cat="bat"'
)
files=("$HOME/.bashrc" "$HOME/.zshrc")

for alias in "${aliases[@]}"; do
	print_message "Processing alias: $alias"
	for file in "${files[@]}"; do
		if [ -f "$file" ]; then
			if grep -Fq "$alias" "$file"; then
				print_message "Alias already exists in $file"
			else
				echo "$alias" >>"$file"
				print_message "Alias added to $file"
			fi
		else
			print_message "$file does not exist, skipping."
		fi
	done
done
