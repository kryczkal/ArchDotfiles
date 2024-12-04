return {
    'Civitasv/cmake-tools.nvim',
    ft = { "cpp", "c", "h", "hpp", "hxx", "cxx", "cc", "tpp", "ipp", "inl", "cmake" },
    config = function()
      local setup = require("config.cmake-tools").setup
      require("cmake-tools").setup(setup)
    end
}
