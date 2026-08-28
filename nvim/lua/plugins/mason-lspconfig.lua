-- lua/plugins/mason-lspconfig.lua
-- Dependency of the lsp plugin; ensures mason-lspconfig is installed
-- and runs its setup after mason is ready.
return {
  "williamboman/mason-lspconfig.nvim",
  after = { "mason.nvim" },   -- load after mason is available
  config = function()
    -- We don't need to do anything here; the actual setup happens
    -- in the lsp plugin's config (where we call require("mason-lspconfig").setup()).
  end,
}