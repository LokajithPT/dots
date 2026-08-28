

return {
    "git@github.com:nvim-telescope/telescope.nvim.git",

    keys = {
        {
            "<C-p>",
           "<cmd> Telescope find_files<cr>" ,
           desc = "find files ",
        },
        {
            "<C-f>",
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
    }
}
