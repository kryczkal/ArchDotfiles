-- File Explorer
return {
    {
        "nvim-tree/nvim-tree.lua",
        cmd = { "NvimTreeToggle", "NvimTreeFocus" },
        config = function()
            local nvim_tree_config = require("config.nvim-tree")
            require("nvim-tree").setup(nvim_tree_config.setup)
        end
    },
}
