-- lua/plugins/ui-select.lua
-- Routes `vim.ui.select` (Flutter devices/emulators/commands, LSP code
-- actions, ...) through Telescope instead of the plain cmdline prompt.
return {
  "nvim-telescope/telescope-ui-select.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  config = function()
    require("telescope").load_extension("ui-select")
  end,
}
