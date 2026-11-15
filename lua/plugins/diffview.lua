return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
  config = function()
    require("diffview").setup({
      diff_binaries = false,
      enhanced_diff_hl = false,
      use_icons = true,
      signs = {
        fold_closed = "",
        fold_open = "",
        done = "✓",
      },
      file_panel = {
        listing_style = "tree",
        win_config = {
          position = "left",
          width = 35,
        },
      },
      file_history_panel = {
        log_options = {
          git = {
            single_file = {
              max_count = 256,
              follow = false,
              all = false,
              merges = false,
            },
            multi_file = {
              max_count = 256,
              follow = false,
              all = false,
              merges = false,
            },
          },
        },
        win_config = {
          position = "bottom",
          height = 16,
        },
      },
      key_bindings = {
        disable_defaults = false,
        view = {
          ["q"] = "<cmd>DiffviewClose<cr>",
        },
        file_panel = {
          ["q"] = "<cmd>DiffviewClose<cr>",
        },
        file_history_panel = {
          ["q"] = "<cmd>DiffviewClose<cr>",
        },
      },
    })
  end,
}
