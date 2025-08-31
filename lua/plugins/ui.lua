---@diagnostic disable: undefined-global
return {

    {
        -- 缩进线
        "lukas-reineke/indent-blankline.nvim",
        event = "VeryLazy",
        config = function()
            require("ibl").setup({
                indent = { char = "┆" }, -- 设置缩进线样式
                scope = { enabled = true }, -- 高亮当前代码块缩进
            })
        end,
    },

    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        config = function()
            vim.opt.laststatus = 2
            vim.opt.showtabline = 2

            require("lualine").setup({
                options = {
                    -- theme = 'minimalist',
                    theme = "auto",
                    icons_enabled = true,
                    always_divide_middle = true,
                    globalstatus = false,
                },
                sections = {
                    -- 左侧：仅在活跃窗口显示文件名
                    lualine_b = {
                        function()
                            if vim.fn.win_getid() == vim.fn.win_getid(vim.fn.winnr()) then
                                return vim.fn.expand("%:t") .. (vim.bo.modified and " [+]" or "")
                            end
                            return ""
                        end,
                    },
                    lualine_c = { "branch" },
                    -- 右侧：始终显示缓冲区编号和文件名
                    lualine_z = {
                        function()
                            local bufnr = vim.api.nvim_get_current_buf()
                            local name = vim.fn.expand("%:t")
                            return string.format("❮%d❯ %s", bufnr, name)
                        end,
                    },
                    lualine_x = {},
                    lualine_y = {},
                },
                inactive_sections = {
                    lualine_b = {},
                    lualine_c = {},
                    lualine_x = {},
                    lualine_y = {},
                    -- 右侧：非激活窗口也显示编号和文件名
                    lualine_z = {
                        function()
                            local bufnr = vim.api.nvim_get_current_buf()
                            local name = vim.fn.expand("%:t")
                            return string.format("《%d》%s", bufnr, name)
                        end,
                    },
                },
                tabline = {
                    lualine_a = {
                        function()
                            return "tabs"
                        end,
                    },
                    lualine_b = {},
                    lualine_c = {
                        function()
                            local tabs = {}
                            for i = 1, vim.fn.tabpagenr("$") do
                                local winnr = vim.fn.tabpagewinnr(i)
                                local buflist = vim.fn.tabpagebuflist(i)
                                local bufnr = buflist[winnr]
                                local name = vim.fn.bufname(bufnr)
                                name = name ~= "" and vim.fn.fnamemodify(name, ":t") or "[No Name]"

                                -- 检查该 tab 是否有未保存的 buffer
                                local modified = false
                                for _, b in ipairs(buflist) do
                                    if vim.fn.getbufvar(b, "&modified") == 1 then
                                        modified = true
                                        break
                                    end
                                end

                                -- 当前 tab 高亮
                                local current = (i == vim.fn.tabpagenr()) and "%#TabLineSel#" or "%#TabLine#"
                                table.insert(
                                    tabs,
                                    string.format(
                                        "%s %d %s%s ",
                                        current,
                                        i,
                                        name,
                                        modified and " [+]" or ""
                                    )
                                )
                            end
                            return table.concat(tabs)
                        end,
                    },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {
                        'buffers',
                    },
                },
                extensions = {},
            })
        end,
    },

    {
        "nvim-tree/nvim-web-devicons",
        event = "VeryLazy",
        config = function()
            require("nvim-web-devicons").setup({
                -- 可选：自定义图标或颜色
                override = {},
                color_icons = true, -- 启用彩色图标
                default = true,     -- 没有匹配时显示默认图标
            })
        end,
    }

    -- lazy.nvim
    -- {
    -- 	"folke/noice.nvim",
    -- 	event = "VeryLazy",
    -- 	opts = {
    -- 		-- add any options here
    -- 	},
    -- 	dependencies = {
    -- 		-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    -- 		"MunifTanjim/nui.nvim",
    -- 		-- OPTIONAL:
    -- 		--   `nvim-notify` is only needed, if you want to use the notification view.
    -- 		--   If not available, we use `mini` as the fallback
    -- 		"rcarriga/nvim-notify",
    -- 	},
    -- },
}
