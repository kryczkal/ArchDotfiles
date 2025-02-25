#!/usr/bin/env bash
# install_modules_cli.sh - CLI for batch installing modules with dependency resolution.
# It scans the modules directory for *.bash files and reads each module's own dependency list.
# Each module file should define its dependencies with a header like:
#   # MODULE_DEPENDENCIES: module1 module2

set -euo pipefail
IFS=$'\n\t'

INSTALL_MODULES_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
modules_dir="$INSTALL_MODULES_SCRIPT_DIR/../modules"
declare -A module_dependencies
available_modules=()

# --- Scan Modules Directory and Read Dependencies ---
for file in "$modules_dir"/*.bash; do
  if [[ -f "$file" ]]; then
    mod_name=$(basename "$file" .bash)
    deps_line=$(grep -E "^# *MODULE_DEPENDENCIES:" "$file" || true)
    if [[ -n "$deps_line" ]]; then
      deps=$(echo "$deps_line" | sed -E 's/^# *MODULE_DEPENDENCIES:[[:space:]]*//')
    else
      deps=""
    fi
    module_dependencies["$mod_name"]="$deps"
    available_modules+=("$mod_name")
  fi
done

# --- Helper Functions ---

# Display available modules with numbered indices.
display_modules() {
  echo "Available modules:"
  for i in "${!available_modules[@]}"; do
    printf "[%d] %s\n" $((i + 1)) "${available_modules[$i]}"
  done
}

# Read user input as a comma-separated list of module numbers.
read_selection() {
  echo "Enter the numbers of the modules to install (comma separated, e.g., 1,3,5):"
  read -r selection
  IFS=',' read -ra indices <<< "$(echo "$selection" | tr -d ' ')"
  selected=()
  for idx in "${indices[@]}"; do
    if [[ "$idx" =~ ^[0-9]+$ ]] && (( idx >= 1 && idx <= ${#available_modules[@]} )); then
      selected+=("${available_modules[$((idx - 1))]}")
    else
      echo "Invalid selection: $idx"
      exit 1
    fi
  done
}

# Global arrays/associative arrays for dependency resolution.
declare -A resolved
sorted_modules=()

# Recursively resolve dependencies for a given module.
resolve_module() {
  local module="$1"
  # Skip if already processed.
  if [[ -n "${resolved[$module]:-}" ]]; then
    return
  fi
  # Get dependencies (if any) and resolve them first.
  local deps="${module_dependencies[$module]}"
  if [[ -n "$deps" ]]; then
    for dep in $deps; do
      # Check if the dependency exists in our scanned modules.
      if [[ " ${available_modules[*]} " == *" $dep "* ]]; then
        resolve_module "$dep"
      else
        echo "Warning: Module '$module' depends on unknown module '$dep'."
      fi
    done
  fi
  resolved["$module"]=1
  sorted_modules+=("$module")
}

# For each selected module, resolve all dependencies.
topological_sort() {
  sorted_modules=()
  resolved=()
  for mod in "${selected[@]}"; do
    resolve_module "$mod"
  done
}

# --- Main Execution Flow ---
main() {
  echo "Module Installation CLI"
  echo "-----------------------"
  display_modules
  read_selection
  echo "Selected modules: ${selected[*]}"

  # Resolve dependencies and determine installation order.
  topological_sort

  # Remove duplicates while preserving order.
  declare -A seen
  final_order=()
  for mod in "${sorted_modules[@]}"; do
    if [[ -z "${seen[$mod]:-}" ]]; then
      final_order+=("$mod")
      seen["$mod"]=1
    fi
  done

  echo "Modules will be installed in the following order:"
  for mod in "${final_order[@]}"; do
    echo " - $mod"
  done

  read -p "Press Enter to start installation, or Ctrl+C to cancel." dummy

  # Execute each module script in order.
  for mod in "${final_order[@]}"; do
    script_path="$modules_dir/${mod}.bash"
    if [[ -x "$script_path" ]]; then
      echo "Executing $script_path..."
      # Change to the script's directory so that relative paths work.
      pushd "$(dirname "$script_path")" > /dev/null
      bash "$(basename "$script_path")"
      popd > /dev/null
    else
      echo "Script not found or not executable: $script_path"
    fi
  done

  echo "Installation complete."
}

main "$@"