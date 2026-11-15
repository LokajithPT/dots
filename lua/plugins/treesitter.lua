return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSInstall lua rust bash json markdown yaml toml dart",
  config = function()
    require("nvim-treesitter").setup()
    -- Keep the Dart parser available for Flutter buffers (no-op if installed).
    require("nvim-treesitter").install({ "dart" })
  end,
}
