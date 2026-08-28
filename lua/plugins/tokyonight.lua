-- lua/plugins/tokyonight.lua
-- TokyoNight theme spec for lazy.nvim
-- This plugin sets the colorscheme to TokyoNight when Neovim starts.

return {
  "folke/tokyonight.nvim",
  lazy = false,          -- Load immediately, not on-demand
  priority = 1000,       -- High priority so it loads before other plugins
  config = function()
    -- Load the default TokyoNight variant (storm, night, horizon, teren)
    vim.cmd("colorscheme tokyonight")
    -- Optional: enable any theme-specific options here
    -- Example: vim.cmd("require('tokyonight').setup{...}")
  end,
}