!#/bin/bash
paru -S --noconfirm bat
paru -S --noconfirm lsd
paru -S --noconfirm procs
paru -S --noconfirm hexyl
paru -S --noconfirm xplr
paru -S --noconfirm fd
paru -S --noconfirm bottom

echo "Do you want to change .zshrc to have colored -h and man? (yes/no)"
read answer

# Convert the answer to lowercase to simplify matching
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
# Define the aliases to check and append
ALIAS1="alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'"
ALIAS2="alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'"
# Define the exports to check and append
EXPORT1='export MANPAGER="sh -c '\''col -bx | bat -l man -p'\''"'
EXPORT2='export MANROFFOPT="-c"'
# Define the path to the .zshrc file
ZSHRC_FILE="$HOME/.zshrc"
# Define the path to the .profile file
PROFILE_FILE="$HOME/.profile"

# General function to append a string to a file if it does not exist
append_if_not_exists() {
    local string_to_append="$1"
    local target_file="$2"

    if ! grep -Fq "$string_to_append" "$target_file"; then
        echo "$string_to_append" >> "$target_file"
        echo "Appended to $target_file: $string_to_append"
    else
        echo "Already in $target_file: $string_to_append"
    fi
}

# Check the user's answer
if [ "$answer" = "yes" ] || [ "$answer" = "y" ]; then
    # Code to execute if user answers yes
    # Check and append the aliases
    append_if_not_exists "$ALIAS1" "$ZSHRC_FILE"
    append_if_not_exists "$ALIAS2" "$ZSHRC_FILE"
    # Check and append the exports
    append_if_not_exists "$EXPORT1" "$PROFILE_FILE"
    append_if_not_exists "$EXPORT2" "$PROFILE_FILE"
    echo "$PROFILE_FILE and $ZSHRC_FILE have been updated."
    echo "Changes will take place after reboot or manual sourcing of $PROFILE_FILE"

elif [ "$answer" = "no" ] || [ "$answer" = "n" ]; then
    # Code to execute if user answers no
    echo "You chose not to proceed."

else
    # Inform the user if the response is not recognized
    echo "Invalid response. Interpreting as 'no'"
fi
