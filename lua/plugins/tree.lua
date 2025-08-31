---@diagnostic disable: undefined-global
return {

    {
        {
            "kshenoy/vim-signature",
        },
    },

    {
        "nvim-tree/nvim-tree.lua",
        -- version = "*",
        event = "VeryLazy",
        config = function()
            require("nvim-tree").setup({

                -- sort =
                -- {
                --     sorter = "case_sensitive",
                -- },
                sort_by = "case_sensitive",
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
        "luckasRanarison/symbols-outline.nvim",
        event = "VeryLazy",
        cmd = "SymbolsOutline",
        dependencies = {
            "nvim-tree/nvim-web-devicons", -- 图标支持
        },
        keys = {
            {
                "<leader>o",
                "<cmd>SymbolsOutline<CR>",
                desc = "Toggle Symbols Outline"
            }
        },
        config = function()
            local ok, outline = pcall(require, "symbols-outline")
            if not ok then
                vim.notify("symbols-outline.nvim 加载失败", vim.log.levels.ERROR)
                return
            end
            outline.setup({
                width = 25,                    -- 侧边栏宽度
                autofold_depth = 1,            -- 默认折叠层级
                auto_close = false,            -- 不自动关闭
                show_symbol_details = true,    -- 显示符号详情
                highlight_hovered_item = true, -- 高亮悬停项
                show_guides = true,            -- 显示缩进线
            })
        end
    },

    -- {
    -- "preservim/tagbar",
    -- version = "VeryLazy",
    -- cmd = "TagbarToggle",
    -- keys = { {
    -- "<leader>o",
    -- "<cmd>TagbarToggle<CR>",
    -- desc = "Toggle Tagbar"
    -- } },
    -- config = function()
    -- vim.g.tagbar_autofocus =
    -- 1
    -- vim.g.tagbar_width = 30
    -- vim.g.tagbar_sort = 0
    -- end
    -- },

    {
        "liuchengxu/vista.vim",
        event = "VeryLazy", -- 启动时不自动加载，按需加载
        config = function()
            -- 设置侧边栏宽度
            vim.g.vista_sidebar_width = 40
            -- 默认使用 LSP，如果没有 LSP 则用 ctags
            vim.g.vista_default_executive = 'nvim_lsp'
            -- 自动关闭/打开
            vim.g.vista_close_on_jump = 1

            -- 快捷键：<leader>v 打开/关闭 Vista 侧边栏
            vim.keymap.set("n", "<leader>v", ":Vista!!<CR>", { noremap = true, silent = true, desc = "Toggle Vista" })
            -- 快捷键：<leader>V 打开/关闭 Vista Finder（符号搜索）
            vim.keymap.set("n", "<leader>V", ":Vista finder<CR>",
                { noremap = true, silent = true, desc = "Vista Finder" })
        end,
    }

}
