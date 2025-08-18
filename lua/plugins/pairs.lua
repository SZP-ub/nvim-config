---@diagnostic disable: undefined-global
return {

    {
        "echasnovski/mini.pairs",
        version = false,       -- 使用最新主分支
        event = "InsertEnter", -- 在插入模式时加载
        config = function()
            require("mini.pairs").setup()
            -- 你可以在这里自定义配置，例如：
            -- require("mini.pairs").setup({
            --   mappings = {
            --     ["'"] = { action = "open", pair = "''", neigh_pattern = "[^%a\\]" },
            --   },
            -- })
        end,
    },

    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup()
        end,
    },


    {
        "HiPhish/rainbow-delimiters.nvim",
        event = "VeryLazy",
        config = function()
            require('rainbow-delimiters.setup').setup {
                strategy = {
                    [''] = 'rainbow-delimiters.strategy.global',
                    vim = 'rainbow-delimiters.strategy.local',
                },
                query = {
                    [''] = 'rainbow-delimiters',
                    lua = 'rainbow-blocks',
                },
                priority = {
                    [''] = 110,
                    lua = 210,
                },
            }
            vim.cmd [[
  hi MatchParen guibg=#444444 guifg=#ff8800 gui=bold
]]
        end,
    },
}
