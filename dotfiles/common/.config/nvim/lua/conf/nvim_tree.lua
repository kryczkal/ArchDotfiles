return {
	hijack_cursor = true,
	view = {
		side = "right",
		adaptive_size = true,
		preserve_window_proportions = true,
	},
	renderer = {
		indent_markers = { enable = true },
		highlight_git = true,
		root_folder_label = false,
	},
	filters = { dotfiles = false },
	actions = {
		open_file = { resize_window = true },
	},
}
