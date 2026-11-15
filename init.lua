require("config.lazy")

-----------------------------------------------------------------
-- Editor defaults
-----------------------------------------------------------------
vim.opt.number = true
vim.o.winborder = "rounded"
vim.opt.signcolumn = "yes"    -- LSP/diagnostic gutter never jumps around
vim.opt.splitbelow = true     -- :split opens below, not above
vim.opt.splitright = true     -- :vsplit opens right, not left
vim.opt.ignorecase = true     -- search: case-insensitive ...
vim.opt.smartcase = true      -- ... unless the pattern has an UPPERCASE char
vim.opt.scrolloff = 5         -- keep 5 lines of context above/below cursor
vim.opt.updatetime = 250      -- faster CursorHold/GitSigns-style updates
vim.opt.undofile = true       -- undo history survives closing the file

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

-- Use system clipboard for yank/paste.
-- (clipboard=unnamedplus alone does this correctly for every operator;
--  the old explicit y/Y mappings broke native yank motions.)
vim.opt.clipboard = 'unnamedplus'

-- Toggle NvimTree
vim.keymap.set('n', '<C-n>', function() require('nvim-tree.api').tree.toggle() end, { noremap = true, silent = true, desc = 'Toggle NvimTree' })
vim.keymap.set('n', '<leader>e', function() require('nvim-tree.api').tree.toggle() end, { noremap = true, silent = true, desc = 'Toggle NvimTree' })

-----------------------------------------------------------------
-- Git keymaps
-----------------------------------------------------------------
local git_opts = { noremap = true, silent = true }

-- Neogit: full Git UI (commit, stage, branch, rebase, push/pull, etc.)
vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<CR>", vim.tbl_extend("force", git_opts, { desc = "Git: open Neogit UI" }))

-- diffview: merge conflicts & diff reviews
vim.keymap.set("n", "<leader>do", "<cmd>DiffviewOpen<CR>", vim.tbl_extend("force", git_opts, { desc = "Diffview: open diff" }))
vim.keymap.set("n", "<leader>dc", "<cmd>DiffviewClose<CR>", vim.tbl_extend("force", git_opts, { desc = "Diffview: close" }))
vim.keymap.set("n", "<leader>dh", "<cmd>DiffviewFileHistory %<CR>", vim.tbl_extend("force", git_opts, { desc = "Diffview: file history" }))
vim.keymap.set("n", "<leader>dH", "<cmd>DiffviewFileHistory<CR>", vim.tbl_extend("force", git_opts, { desc = "Diffview: branch history" }))

-- gitsigns: stage/unstage/reset hunks
vim.keymap.set("n", "<leader>gs", function() require("gitsigns").stage_hunk() end, vim.tbl_extend("force", git_opts, { desc = "Git: stage hunk" }))
vim.keymap.set("n", "<leader>gr", function() require("gitsigns").reset_hunk() end, vim.tbl_extend("force", git_opts, { desc = "Git: reset hunk" }))
vim.keymap.set("n", "<leader>gp", function() require("gitsigns").preview_hunk() end, vim.tbl_extend("force", git_opts, { desc = "Git: preview hunk" }))
vim.keymap.set("n", "<leader>gb", function() require("gitsigns").blame_line() end, vim.tbl_extend("force", git_opts, { desc = "Git: blame line" }))
vim.keymap.set("n", "<leader>gd", function() require("gitsigns").diffthis() end, vim.tbl_extend("force", git_opts, { desc = "Git: diff this buffer" }))
vim.keymap.set("n", "<leader>gS", function() require("gitsigns").stage_buffer() end, vim.tbl_extend("force", git_opts, { desc = "Git: stage whole buffer" }))
vim.keymap.set("n", "<leader>gR", function() require("gitsigns").reset_buffer() end, vim.tbl_extend("force", git_opts, { desc = "Git: reset whole buffer" }))

-- octo: GitHub PRs & issues (requires GITHUB_TOKEN)
vim.keymap.set("n", "<leader>oc", "<cmd>Octo pr list<CR>", vim.tbl_extend("force", git_opts, { desc = "Octo: list pull requests" }))
vim.keymap.set("n", "<leader>oi", "<cmd>Octo issue list<CR>", vim.tbl_extend("force", git_opts, { desc = "Octo: list issues" }))
