#!/bin/bash

help() {
    echo "Usage: $0 [options] [files and/or directories]"
    echo
    echo "Options:"
    echo "  -r, --recursive              Recurse into directories"
    echo "  -l, --label                  Print the file name before its contents"
    echo "  -o, --output <file>          Specify output file (default: stdout)"
    echo "  -I, --ignore <regex>         Ignore files matching this regex (can be given multiple times)"
    echo "  -h, --help                   Show this help message and exit"
    echo
    echo "Examples:"
    echo "  $0 -l -o combined.txt file1.txt dir1"
    echo "  $0 -r -I '.*\\.bak' -I '^test_' dir2"
    echo
}

parse_args() {
    RECURSIVE=false
    LABEL=false
    OUTPUT=""
    IGNORE_PATTERNS=()

    # Collect positional arguments after parsing
    FILES_AND_DIRS=()

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
            *)
                FILES_AND_DIRS+=("$1")
                shift
                ;;
        esac
    done
}

main() {
    parse_args "$@"

    # Gather all files to process
    ALL_FILES=()
    for ITEM in "${FILES_AND_DIRS[@]}"; do
        if [[ -d "$ITEM" ]]; then
            if $RECURSIVE; then
                # Recursively find all files in the directory
                while IFS= read -r -d $'\0' FOUND; do
                    ALL_FILES+=("$FOUND")
                done < <(find "$ITEM" -type f -print0)
            else
                # Only take direct files in the directory, no recursion
                while IFS= read -r -d $'\0' FOUND; do
                    ALL_FILES+=("$FOUND")
                done < <(find "$ITEM" -maxdepth 1 -type f -print0)
            fi
        elif [[ -f "$ITEM" ]]; then
            ALL_FILES+=("$ITEM")
        fi
    done

    # Filter out ignored files
    # If no ignore patterns, keep all files. If patterns given, remove matches.
    if (( ${#IGNORE_PATTERNS[@]} > 0 )); then
        FILTERED_FILES=()
        for F in "${ALL_FILES[@]}"; do
            IGNORE_THIS=false
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
        ALL_FILES=("${FILTERED_FILES[@]}")
    fi

    # If an output file is specified, clear or create it first
    if [[ -n "$OUTPUT" ]]; then
        > "$OUTPUT"
    fi

    # Process each file, optionally labeling, and concatenate contents
    for FILE in "${ALL_FILES[@]}"; do
        if $LABEL; then
            if [[ -n "$OUTPUT" ]]; then
                echo "=== $FILE ===" >> "$OUTPUT"
            else
                echo "=== $FILE ==="
            fi
        fi
        if [[ -n "$OUTPUT" ]]; then
            cat "$FILE" >> "$OUTPUT"
        else
            cat "$FILE"
        fi
    done
}

main "$@"

