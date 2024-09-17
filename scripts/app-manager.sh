#!/bin/env bash
set -e
browser_executable_path="/usr/bin/chromium"
desktop_files_path="$HOME/.local/share/applications"

#
# Utils
#
function print_usage() {
  echo "Usage: app-manager.sh [OPTION] [ARGUMENT]"
  echo "Options:"
  echo "  -h, --help      Show this help message and exit"
  echo "  -m  --make      Make an application [ARGUMENT: app_name app_url]"
  echo "  -u, --uninstall Delete an application [ARGUMENT: app_name]"
  echo "  -s, --search    List all applications"
}

function is_web_app () {
  cd "${desktop_files_path}"

  file_name="$1"
  if ! [[ "$file_name" == *".desktop" ]]; then
    return 1
  fi

  if ! [[ -f "$file_name" ]]; then
    return 1
  fi

  file_content=$(cat "$file_name")
  exec_line=$(echo "$file_content" | grep "^Exec=")
  if [[ -z "$exec_line" ]]; then
    return 1
  fi

  if [[ "$exec_line" == *"-app="* ]]; then
    return 0
  else
    return 1
  fi
}


#
# Core Functions
#
function make_app () {
  local app_name="$1"
  local app_url="$2"

  if [[ -z "$app_name" ]] || [[ -z "$app_url" ]]; then
    echo "Please provide app_name and app_url"
    exit 1
  fi

  local app_dekstop_file_template="[Desktop Entry]
  Name=${app_name}
  Exec=${browser_executable_path} -app=${app_url}
  Type=Application
  "
  # properly format the template
  app_dekstop_file_template=$(echo "$app_dekstop_file_template" | sed -e 's/^[[:space:]]*//')

  local normalized_app_name=$(echo "$app_name" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]')

  cd
  local app_desktop_file_path="./.local/share/applications/${normalized_app_name}.desktop"
  echo "$app_dekstop_file_template" > "$app_desktop_file_path"
  echo "Application $app_name has been created"
}

function uninstall_app () {
  cd "${desktop_files_path}"

  local app_name="$1"
  local normalized_app_name=$(echo "$app_name" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]')
  local app_desktop_file_path="${normalized_app_name}.desktop"
  if is_web_app "$normalized_app_name"; then
    echo "Application $app_name is not a web app"
    exit 1
  fi

  if [[ -f "$app_desktop_file_path" ]]; then
    rm "$app_desktop_file_path"
    echo "Application $app_name has been deleted"
  else
    echo "Application $app_name not found"
  fi
}

function search_apps () {
  cd "${desktop_files_path}"

  for file in *.desktop; do
    if is_web_app "$file"; then
      app_name=$(echo "$file" | cut -d'.' -f1)
      echo "$app_name"
    fi
  done
}


#
# Script
#
args=("$@")
case "$1" in
  -m|--make)
    make_app "${args[1]}" "${args[2]}"
    ;;
  -u|--uninstall)
    uninstall_app "${args[1]}"
    ;;
  -s|--search)
    search_apps
    ;;
  *)
    print_usage
    ;;
esac
