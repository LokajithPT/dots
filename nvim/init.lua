require("config.lazy")
vim.opt.number = true

-- Use system clipboard for yank/paste
vim.opt.clipboard = 'unnamedplus'
-- Optional explicit mappings (normally works with unnamedplus)
vim.keymap.set({ 'n','v' }, 'y', '"+y', { noremap = true, silent = true })
vim.keymap.set({ 'n','v' }, 'Y', '"+Y', { noremap = true, silent = true })

-- Toggle NvimTree with <C-n>
vim.keymap.set('n','<C-n>',':NvimTreeToggle<CR>',{noremap=true,silent=true})
