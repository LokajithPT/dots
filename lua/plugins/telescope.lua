

return {
    -- Plain slug: the old SSH URL (git@github.com:...) failed to clone/update
    -- on any machine without GitHub SSH keys. Same resolved plugin name, so
    -- the already-installed copy is reused.
    "nvim-telescope/telescope.nvim",

    keys = {
        {
            "<C-p>",
           "<cmd> Telescope find_files<cr>" ,
           desc = "find files ",
        },
        {
            "<leader>fg",
            "<cmd>Telescope live_grep<cr>",
            desc = "live grep",
        },
    },

    opts = {
        defaults = {
            layout_strategy = "horizontal",
            layout_config = {
                prompt_position = "top",
            }, 
            sorting_strategy = "ascending",
        }
    },

    config = function(_, opts)
        require("telescope").setup(opts)
        require("telescope").load_extension("harpoon")
    end,
}
