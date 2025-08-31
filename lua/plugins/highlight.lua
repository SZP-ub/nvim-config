---@diagnostic disable: undefined-global
return {

    {
        "nvim-treesitter/nvim-treesitter",
        -- event = { "BufReadPost", "BufNewFile" },
        event = "VeryLazy",
        build = ":TSUpdate",
        main = "nvim-treesitter.configs",
        opts = {
            auto_install = true,
            ensure_installed = {
                "c", "cpp", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html", "json", "markdown",
                "latex",
            },
            sync_install = false,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            indent = { enable = true },
        },
        opts_extend = { "ensure_installed" },
    },
}
