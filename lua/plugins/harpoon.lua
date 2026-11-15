return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    local harpoon = require('harpoon')

    harpoon:setup({
      menu = {
        -- Scale the menu with the window instead of harpoon's fixed 60 cols
        width = math.min(vim.o.columns - 4, 80),
        height = math.min(vim.o.lines - 2, 24),
      },
      settings = {
        -- Persist the list (reorder/delete) when closing the menu
        save_on_toggle = true,
      },
    })

    -- Primary mappings

    -- Mark the current file
    vim.keymap.set('n', '<C-a>', function() harpoon:list():add() end,
      { noremap = true, silent = true, desc = 'Harpoon: add file' })

    -- Open the harpoon list menu
    vim.keymap.set('n', '<C-f>', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
      { noremap = true, silent = true, desc = 'Harpoon: list menu' })

    -- Navigate the list (j = down/next, k = up/prev)
    vim.keymap.set('n', '<C-j>', function() harpoon:list():next() end,
      { noremap = true, silent = true, desc = 'Harpoon: next' })
    vim.keymap.set('n', '<C-k>', function() harpoon:list():prev() end,
      { noremap = true, silent = true, desc = 'Harpoon: prev' })

    -- Secondary mappings

    -- Drop the current file from the list
    vim.keymap.set('n', '<leader>hd', function() harpoon:list():remove() end,
      { noremap = true, silent = true, desc = 'Harpoon: delete file' })

    -- Pick a harpooned file with telescope instead of the built-in menu.
    -- The extension exports the picker as `marks` — the old
    -- `builtin.harpoon()` lookup raised "picker not found".
    vim.keymap.set('n', '<leader>hf', function()
      require('telescope').extensions.harpoon.marks()
    end, { noremap = true, silent = true, desc = 'Harpoon: find files' })

    -- Start a separate list (e.g. per-project scratch lists)
    vim.keymap.set('n', '<leader>hm', function()
      vim.ui.input({ prompt = 'Harpoon list name: ' }, function(name)
        if name and vim.trim(name) ~= '' then harpoon:list(name) end
      end)
    end, { noremap = true, silent = true, desc = 'Harpoon: new list' })
  end,
}
