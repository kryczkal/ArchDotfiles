#!/bin/bash

# --- Default Configuration ---
RECURSIVE=false
LABEL=false
CLIPBOARD=false
OUTPUT=""
IGNORE_PATTERNS=()
FILES_AND_DIRS=()

help() {
    echo "Usage: $0 [options] [files and/or directories]"
    echo
    echo "Concatenates files. If run with no arguments, it will try to load settings"
    echo "from a 'concat.conf' file in the current directory."
    echo
    echo "Options:"
    echo "  -r, --recursive              Recurse into directories"
    echo "  -l, --label                  Print the file name before its contents"
    echo "  -c, --clip                   Copy the output to the clipboard (uses wl-copy or xclip)"
    echo "  -o, --output <file>          Specify output file (default: stdout)"
    echo "  -I, --ignore <regex>         Ignore files/paths matching this regex (can be given multiple times)"
    echo "      --config <file>          Use a specific configuration file"
    echo "  -h, --help                   Show this help message and exit"
    echo
    echo "Examples:"
    echo "  $0                           # Load settings from ./concat.conf"
    echo "  $0 -l -o combined.txt file1.txt dir1"
    echo "  $0 --config project.conf -c  # Load from project.conf and copy to clipboard"
    echo
}

# Find the best available command for clipboard operations
get_clipboard_cmd() {
    if command -v wl-copy &> /dev/null; then
        echo "wl-copy"
    elif command -v xclip &> /dev/null; then
        echo "xclip -selection clipboard"
    else
        echo ""
    fi
}

parse_args() {
    # If --config is present, source it first. This allows its values
    # to be overridden by any subsequent command-line arguments.
    local temp_args=()
    while [[ $# -gt 0 ]]; do
        if [[ "$1" == "--config" ]]; then
            if [[ -f "$2" ]]; then
                # Sourcing sets the variables defined in the config file.
                # shellcheck source=/dev/null
                source "$2"
            else
                echo "Error: Config file not found: $2" >&2
                exit 1
            fi
            shift 2
        else
            temp_args+=("$1")
            shift
        fi
    done
    # Restore remaining arguments
    set -- "${temp_args[@]}"

    # If no arguments were originally passed (and no --config), try to load default ./concat.conf
    if [[ ${#temp_args[@]} -eq 0 && -f "concat.conf" ]]; then
        # shellcheck source=/dev/null
        source "concat.conf"
        # No more args to parse, so we can return
        return
    fi

    # Parse command-line arguments, which will override any values from a sourced config file.
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -r|--recursive)
                RECURSIVE=true
                shift
                ;;
            -l|--label)
                LABEL=true
                shift
                ;;
            -c|--clip)
                CLIPBOARD=true
                shift
                ;;
            -o|--output)
                OUTPUT="$2"
                shift 2
                ;;
            -I|--ignore)
                IGNORE_PATTERNS+=("$2")
                shift 2
                ;;
            -h|--help)
                help
                exit 0
                ;;
            -*)
                echo "Error: Unknown option: $1" >&2
                help
                exit 1
                ;;
            *)
                FILES_AND_DIRS+=("$1")
                shift
                ;;
        esac
    done
}

main() {
    parse_args "$@"

    if [[ ${#FILES_AND_DIRS[@]} -eq 0 ]]; then
        echo "Error: No input files or directories specified." >&2
        help
        exit 1
    fi

    ALL_FILES=()
    for ITEM in "${FILES_AND_DIRS[@]}"; do
        if [[ -d "$ITEM" ]]; then
            local find_cmd=("find" "$ITEM" "-type" "f" "-print0")
            if ! $RECURSIVE; then
                find_cmd=(-maxdepth 1 "${find_cmd[@]}")
            fi
            while IFS= read -r -d $'\0' FOUND; do
                ALL_FILES+=("$FOUND")
            done < <("${find_cmd[@]}")
        elif [[ -f "$ITEM" ]]; then
            ALL_FILES+=("$ITEM")
        else
            echo "Warning: '$ITEM' is not a valid file or directory. Skipping." >&2
        fi
    done

    FILTERED_FILES=()
    if (( ${#IGNORE_PATTERNS[@]} > 0 )); then
        for F in "${ALL_FILES[@]}"; do
            local IGNORE_THIS=false
            for PAT in "${IGNORE_PATTERNS[@]}"; do
                if [[ "$F" =~ $PAT ]]; then
                    IGNORE_THIS=true
                    break
                fi
            done
            if ! $IGNORE_THIS; then
                FILTERED_FILES+=("$F")
            fi
        done
    else
        FILTERED_FILES=("${ALL_FILES[@]}")
    fi

    # Use a temporary file to build the output
    TEMP_FILE=$(mktemp)
    trap 'rm -f "$TEMP_FILE"' EXIT

    for FILE in "${FILTERED_FILES[@]}"; do
        if $LABEL; then
            echo "=== $FILE ===" >> "$TEMP_FILE"
        fi
        cat "$FILE" >> "$TEMP_FILE"
        # Add a newline between files for better separation
        echo "" >> "$TEMP_FILE"
    done

    # Direct output based on flags
    if $CLIPBOARD; then
        local clip_cmd
        clip_cmd=$(get_clipboard_cmd)
        if [[ -n "$clip_cmd" ]]; then
            cat "$TEMP_FILE" | $clip_cmd
            echo "Output copied to clipboard." >&2
        else
            echo "Error: No clipboard tool (wl-copy or xclip) found." >&2
            exit 1
        fi
    elif [[ -n "$OUTPUT" ]]; then
        cat "$TEMP_FILE" > "$OUTPUT"
    else
        cat "$TEMP_FILE"
    fi
}

main "$@"

