---@diagnostic disable: undefined-global
return {

    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        config = function()
            require("nvim-tree").setup({

                sort =
                {
                    sorter = "case_sensitive",
                },
                view =
                {
                    width = 20,
                },
                renderer =
                {
                    group_empty = true,
                },
                filters =
                {
                    dotfiles = true,
                },
            })
        end,
    },

    {
        "preservim/tagbar",
        version = "VeryLazy",
        cmd = "TagbarToggle",
        keys = { {
            "<leader>o",
            "<cmd>TagbarToggle<CR>",
            desc = "Toggle Tagbar"
        } },
        config = function()
            vim.g.tagbar_autofocus =
                1
            vim.g.tagbar_width = 30
            vim.g.tagbar_sort = 0
        end
    }
}
