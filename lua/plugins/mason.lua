-- lua/plugins/mason.lua
-- Installs the :Mason UI for managing LSP servers, linters, formatters, etc.
return {
  "williamboman/mason.nvim",
  config = function()
    require("mason").setup()
  end,
}