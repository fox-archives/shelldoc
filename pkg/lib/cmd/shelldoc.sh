# shellcheck shell=bash

main.shelldoc() {
	declare -A args=()
	bash-args parse "$@" <<-"EOF"
		@arg run - Build project
		@flag [help.h] - Show help menu
	EOF

	if [ "${args[help]}" = 'yes' ]; then
		printf '%s\n' "$argsHelpText"
	fi

	if ! command -v shdoc &>/dev/null; then
		printf '%s\n' "Error: shdoc not installed"
	fi

	local input_dir="${argsCommands[0]}"

	if [ -z "$input_dir" ]; then
		printf '%s\n' "Error: Directory cannot be empty"
		exit 1
	fi

	if [ ! -d "$input_dir" ]; then
		printf '%s\n' "Error: Directory '$input_dir' does not exist"
		exit 1
	fi

	shopt -s nullglob
	shopt -s extglob
	# TODO: absolute paths do not work
	input_dir="${input_dir#./}"
	for dir in "$PWD/$input_dir"/**/*/; do
		for file in "${dir::-1}"/*.{bash,sh}; do
			printf '%s\n' "./${file:${#PWD}+1}"
			mkdir -p "./doc_output/${file%/*}"
			shdoc < "$file" > "./doc_output/$file"

			if [ -s "./doc_output/$file" ]; then
				rm "./doc_output/$file"
			fi
		done; unset file
	done; unset dir
}
