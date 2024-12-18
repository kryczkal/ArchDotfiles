set -e
source "$(dirname "$0")/utils.sh"
way_displays_config="$HOME/.config/way-displays/cfg.yaml"

rearrange_monitors ()
{
  outputs=()
  get_connected_outputs outputs
  if [ ${#outputs[@]} -eq 0 ]; then
      echo "No connected outputs found."
      exit 1
  fi

  echo "Available outputs:"
  for output in "${outputs[@]}"; do
      echo "$output"
  done

  if [ ! -f "$way_displays_config" ]; then
    echo "Config file not found at $way_displays_config"
    exit 1
  fi

  current_monitor_order=$(sed -n -e '/ORDER:/,$p' "$way_displays_config" | grep -E '^[[:space:]]*-' | sed -e 's/^[[:space:]]*-\s*//')
  echo "$current_monitor_order" | sed -e "s/^'//;s/'$//"
}

rearrange_monitors
