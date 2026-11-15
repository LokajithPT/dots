return {
  "TimUntersberger/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "nvim-telescope/telescope.nvim",
  },
  cmd = "Neogit",
  config = function()
    local neogit = require("neogit")
    neogit.setup({
      kind = "tab",
      disable_signs = false,
      disable_hint = false,
      disable_context_highlighting = false,
      disable_commit_confirmation = false,
      disable_insert_on_commit = false,
      enable_cursorholding = true,
      sign_section = {
        header = "",
        items = {
          { section = "head", icon = "•" },
          { section = "remote", icon = "↗" },
          { section = "merge", icon = "↔" },
          { section = "rebase", icon = "↩" },
        },
      },
      integrations = {
        diffview = true,
        telescope = true,
      },
      sections = {
        untracked = { folded = false },
        unstaged = { folded = false },
        staged = { folded = false },
        stashes = { folded = true },
        unpulled = { folded = true },
        unmerged = { folded = false },
        recent = { folded = true },
      },
      mappings = {
        status = {
          ["q"] = "Close",
          ["a"] = "GitAdd",
          ["A"] = "GitAddAll",
          ["u"] = "GitStageUnstaged",
          ["x"] = "GitDiscard",
          ["c"] = "GitCommit",
          ["p"] = "GitPush",
          ["P"] = "GitPull",
          ["b"] = "GitBranch",
          ["z"] = "GitUndo",
          ["y"] = "GitRedo",
        },
      },
    })
  end,
}
