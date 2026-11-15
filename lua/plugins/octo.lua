return {
  "pwntester/octo.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  cmd = "Octo",
  config = function()
    require("octo").setup({
      suppress_missing_scope = {
        projects_v2 = true,
      },
      default_remotes = { "origin" },
      default_merge_method = "commit",
      reaction_viewer_hint_icon = "",
      user_icon = " ",
      timeline_icon = "",
      comment_icon = "",
      issue_icon = " ",
      pull_request_icon = " ",
      ci_icon = " ",
      scoped_icons = {
        folder = " ",
        repo = " ",
      },
    })
  end,
}
