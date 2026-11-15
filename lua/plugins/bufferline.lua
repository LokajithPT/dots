return {
  'akinsho/bufferline.nvim',
  version = "*",
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    require("bufferline").setup({
      options = {
        mode = "buffers",
        separator_style = "thin",
        show_buffer_close_icons = true,
        show_close_icon = false,
        -- (removed a dead `theme = {...}` key here: bufferline has no such
        -- option — only `themable` / `highlights` — so it was silently ignored)
      },
    })
    -- Ctrl-Tab is not forwarded by most terminals, so use <leader><Tab> instead.
    vim.keymap.set('n', '<leader><Tab>', '<cmd>BufferLineCycleNext<CR>',
      { noremap = true, silent = true, desc = "Next tab" })
    vim.keymap.set('n', '<leader>x', '<cmd>bdelete<CR>',
      { noremap = true, silent = true, desc = "Close tab" })
    -- Jump directly to a tab by number (1-9)
    for i = 1, 9 do
      vim.keymap.set('n', '<leader>' .. i,
        '<cmd>BufferLineGoToBuffer ' .. i .. '<CR>',
        { noremap = true, silent = true, desc = "Go to tab " .. i })
    end
  end,
}
