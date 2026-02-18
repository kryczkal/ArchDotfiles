return {
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Navigate Left (tmux/vim)" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Navigate Down (tmux/vim)" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Navigate Up (tmux/vim)" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate Right (tmux/vim)" },
      { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Navigate Previous (tmux/vim)" },
    },
  },
}
