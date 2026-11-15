-- lua/plugins/mason.lua
-- Installs the :Mason UI for managing LSP servers, linters, formatters, etc.
return {
  "williamboman/mason.nvim",
  config = function()
    require("mason").setup({
      ui = {
        border = "rounded",
        width = 0.8,
        height = 0.9,
        backdrop = 100,
        -- winborder = rounded (set globally in init.lua) also fixes vim.ui.select clipping
      },
    })
  end,
}