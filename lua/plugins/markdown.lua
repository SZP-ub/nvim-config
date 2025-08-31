---@diagnostic disable: undefined-global
return {
    {
        "OXY2DEV/markview.nvim",
        ft = { "markdown" },
        priority = 100,
        config = function()
            require("markview").setup()
        end,
    },

    {
        "keaising/im-select.nvim",
        event = "InsertEnter",
        config = function()
            require("im_select").setup({
                default_im_select = "keyboard-cn",
                set_im_select_commands = {
                    Linux = "fcitx5-remote -s %s",
                },
                get_im_select_command = "fcitx5-remote -n | tr -d '\n'",
                get_im_select_timeout = 300
            })
        end,
    }

    -- {
    --     "lervag/vimtex",
    --     lazy = false, -- we don't want to lazy load VimTeX
    --     -- tag = "v2.15", -- uncomment to pin to a specific release
    --     init = function()
    --         -- VimTeX configuration goes here, e.g.
    --         vim.g.vimtex_view_method = "sioyek"
    --         vim.g.vimtex_compiler_method = "latexmk"
    --         vim.g.vimtex_quickfix_mode = 0
    --     end,
    -- },

}
