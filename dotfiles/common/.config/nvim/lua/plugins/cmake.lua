return {
  "Civitasv/cmake-tools.nvim",
  -- Load the plugin when a CMake command is executed OR when a CMakeLists.txt is opened.
  cmd = {
    "CMakeGenerate",
    "CMakeBuild",
    "CMakeRun",
    "CMakeTest",
    "CMakeDebug",
    "CMakeSelectTarget",
  },
  event = { "BufRead CMakeLists.txt" },
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    build_directory = "build/${variant:buildType}",
    cmake_dap_configuration = {
      name = "Launch",
      type = "codelldb",
      request = "launch",
      stopOnEntry = false,
      runInTerminal = true,
      console = "integratedTerminal",
    },
  },
}
