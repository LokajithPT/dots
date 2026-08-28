require("config.lazy")
vim.opt.number = true

-- Disable spell checking (no red squiggles on words)
vim.opt.spell = false

-- Disable grayed-out inactive code regions in Rust (rust-analyzer semantic tokens)
local function clear_inactive_code_hl()
  for _, g in ipairs({ "InactiveCode", "@lsp.mod.inactiveCode", "@lsp.mod.inactiveCode.rust" }) do
    pcall(vim.api.nvim_set_hl, 0, g, { link = "Normal" })
  end
end
clear_inactive_code_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = clear_inactive_code_hl })

-- Use system clipboard for yank/paste
vim.opt.clipboard = 'unnamedplus'
-- Optional explicit mappings (normally works with unnamedplus)
vim.keymap.set({ 'n','v' }, 'y', '"+y', { noremap = true, silent = true })
vim.keymap.set({ 'n','v' }, 'Y', '"+Y', { noremap = true, silent = true })

-- Toggle NvimTree
vim.keymap.set('n', '<C-n>', function() require('nvim-tree.api').tree.toggle() end, { noremap = true, silent = true, desc = 'Toggle NvimTree' })
vim.keymap.set('n', '<leader>e', function() require('nvim-tree.api').tree.toggle() end, { noremap = true, silent = true, desc = 'Toggle NvimTree' })
