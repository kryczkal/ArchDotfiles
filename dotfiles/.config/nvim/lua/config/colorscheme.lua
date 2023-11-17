vim.opt.background = "dark" -- set this to dark or light
function SetColors(color)
	color = color or "vscode" --vscode, midnight, oxocarbon, tokyonight
	vim.cmd.colorscheme(color)

	--" This autocommand will be triggered after the colorscheme is loaded
	vim.cmd[[autocmd ColorScheme * highlight Normal guibg=#000000]]


	vim.api.nvim_set_hl(0, "Normal", { bg = "#000000" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#000000" })
	vim.api.nvim_exec([[
	highlight TelescopeNormal guibg=#000000
	highlight TelescopeBorder guibg=#000000
	highlight TelescopePromptBorder guibg=#000000
	highlight TelescopeResultsBorder guibg=#000000
	highlight TelescopePreviewBorder guibg=#000000
	highlight TelescopeSelection guibg=#000000
	highlight TelescopeMatching guibg=#000000
	]], false)

end

SetColors()


