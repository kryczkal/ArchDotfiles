local config = {}

config.setup = {
  render = {
    min_padding = 5,
    show_label = true,
    show_image_dimensions = true,
    use_dither = true,
    foreground_color = true,
    background_color = true,
  },
  events = {
    update_on_nvim_resize = true,
  },
}

return config
