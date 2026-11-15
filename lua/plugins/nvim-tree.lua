return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require('nvim-tree').setup({
      view = { width = 30 },
      renderer = {
        icons = {
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
          },
        },
      },
      actions = {
        open_file = { quit_on_open = false },
      },
    })
  end,
}
