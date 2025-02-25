#!/usr/bin/env bash
# Add specified users to a set of default groups.
set -euo pipefail
IFS=$'\n\t'

# Must be run as root.
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

source "$(dirname "$0")/../lib/utils.bash"

if [ $# -eq 0 ]; then
  echo "Usage: $0 username1 [username2 ...]"
  exit 1
fi

default_groups="wheel,adm,lp,sys,network,storage,power,audio,video,optical,scanner,users,input"
print_message "Default groups: $default_groups"

for user in "$@"; do
  if id "$user" &>/dev/null; then
    print_message "Processing user: $user"
    IFS=',' read -ra groups <<< "$default_groups"
    for group in "${groups[@]}"; do
      if getent group "$group" > /dev/null; then
        usermod -aG "$group" "$user"
        print_message "Added $user to $group"
      else
        print_message "Group $group does not exist."
      fi
    done
  else
    print_message "User $user does not exist."
  fi
done
