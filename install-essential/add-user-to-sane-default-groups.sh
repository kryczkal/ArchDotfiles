#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Check if no arguments were provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 username1 [username2 ...]"
    echo "Example: $0 alice bob"
    exit 1
fi


# Function to add user to specified groups
add_user_to_groups() {
    local user=$1
    # Define the default groups within the function scope to avoid sudo problems
    local groups="wheel,adm,lp,sys,network,storage,power,audio,video,optical,scanner,users,input"

    echo "Assigned groups: $groups"
    # Check if the user exists
    if id "$user" &>/dev/null; then
        echo "Processing user: $user"
        # Add user to each group
        IFS=',' read -ra GROUP_ARRAY <<< "$groups"
        for group in "${GROUP_ARRAY[@]}"; do
            if grep -q "^$group:" /etc/group; then
                usermod -aG $group $user
                echo "Added $user to $group"
            else
                echo "Group $group does not exist"
            fi
        done
    else
        echo "User $user does not exist"
    fi
}

# Loop through all provided usernames
for user in "$@"; do
    add_user_to_groups $user
done

