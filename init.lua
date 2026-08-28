require("config.lazy")
vim.opt.number = true

-- Toggle NvimTree with <C-n>
vim.keymap.set('n','<C-n>',':NvimTreeToggle<CR>',{noremap=true,silent=true})
