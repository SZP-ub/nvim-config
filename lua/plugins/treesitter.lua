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

    -- coc.nvim

    {
        "neoclide/coc.nvim",
        branch = "release",
        config = function()
            -- K 显示文档
            function _G.ShowDocumentation()
                if vim.fn.CocAction('hasProvider', 'hover') then
                    vim.fn.CocActionAsync('doHover')
                else
                    vim.api.nvim_feedkeys('K', 'in', false)
                end
            end

            -- 智能 Tab 配置 for coc.nvim
            vim.g.coc_snippet_next = '<Tab>'
            vim.g.coc_snippet_prev = '<S-Tab>'

            -- 检查光标前是否是空白
            function _G.check_back_space()
                local col = vim.fn.col('.') - 1
                return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
            end

            -- 智能 Tab 映射
            vim.api.nvim_set_keymap("i", "<Tab>",
                "coc#pum#visible() ? coc#pum#next(1) : coc#expandableOrJumpable() ? '<C-r>=coc#rpc#request(\"doKeymap\", [\"snippets-expand-jump\",\"\"])<CR>' : v:lua.check_back_space() ? '<Tab>' : coc#refresh()",
                { noremap = true, silent = true, expr = true })

            -- 反向跳转（Shift-Tab）
            vim.api.nvim_set_keymap("i", "<S-Tab>",
                "coc#pum#visible() ? coc#pum#prev(1) : coc#jumpable(-1) ? '<C-r>=coc#rpc#request(\"doKeymap\", [\"snippets-expand-jump-back\",\"\"])<CR>' : '<S-Tab>'",
                { noremap = true, silent = true, expr = true })

            -- 回车键确认补全项
            vim.keymap.set("i", "<CR>", function()
                if vim.fn['coc#pum#visible']() == 1 then
                    return vim.fn['coc#pum#confirm']()
                else
                    -- return vim.api.nvim_replace_termcodes("<CR>", true, true, true)
                    return require("mini.pairs").cr()
                end
            end, { expr = true, silent = true, noremap = true })

            -- <C-Space> 触发补全
            vim.keymap.set("i", "<C-Space>", "coc#refresh()", { expr = true, silent = true })

            -- [g 和 ]g 跳转诊断信息
            vim.keymap.set("n", "[g", "<Plug>(coc-diagnostic-prev)", { silent = true })
            vim.keymap.set("n", "]g", "<Plug>(coc-diagnostic-next)", { silent = true })

            -- 代码跳转
            vim.keymap.set("n", "gd", "<Plug>(coc-definition)", { silent = true })
            vim.keymap.set("n", "gy", "<Plug>(coc-type-definition)", { silent = true })
            -- vim.keymap.set("n", "<leader>gi", "<Plug>(coc-implementation)", { silent = true })
            vim.keymap.set("n", "<leader>gi", function()
                vim.fn.CocAction('jumpImplementation')
            end, { silent = true })
            vim.keymap.set("n", "gr", "<Plug>(coc-references)", { silent = true })

            -- K 显示文档
            vim.keymap.set("n", "K", ":lua ShowDocumentation()<CR>", { silent = true })

            -- 光标悬停时高亮符号及引用
            vim.api.nvim_create_autocmd("CursorHold", {
                pattern = "*",
                callback = function()
                    vim.fn.CocActionAsync('highlight')
                end,
            })

            -- 重命名符号
            vim.keymap.set("n", "<leader>rn", "<Plug>(coc-rename)", { silent = true })
            -- 选区代码操作
            vim.keymap.set("x", "<leader>a", "<Plug>(coc-codeaction-selected)", { silent = true })
            vim.keymap.set("n", "<leader>a", "<Plug>(coc-codeaction-selected)", { silent = true })
            -- 光标处代码操作
            vim.keymap.set("n", "<leader>ac", "<Plug>(coc-codeaction-cursor)", { silent = true })
            -- 整个 buffer 代码操作
            vim.keymap.set("n", "<leader>as", "<Plug>(coc-codeaction-source)", { silent = true })
            -- 当前行诊断快速修复
            vim.keymap.set("n", "<leader>qf", "<Plug>(coc-fix-current)", { silent = true })

            -- 重构操作
            vim.keymap.set("n", "<leader>re", "<Plug>(coc-codeaction-refactor)", { silent = true })
            vim.keymap.set("x", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true })
            vim.keymap.set("n", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true })

            -- 运行当前行的 Code Lens
            vim.keymap.set("n", "<leader>cl", "<Plug>(coc-codelens-action)", { silent = true })

            -- Outline
            -- vim.keymap.set("n", "<leader>o", ":CocOutline<CR>", { silent = true })

            -- 函数/类文本对象映射（需要 LSP 支持）
            vim.keymap.set("x", "if", "<Plug>(coc-funcobj-i)")
            vim.keymap.set("o", "if", "<Plug>(coc-funcobj-i)")
            vim.keymap.set("x", "af", "<Plug>(coc-funcobj-a)")
            vim.keymap.set("o", "af", "<Plug>(coc-funcobj-a)")
            vim.keymap.set("x", "ic", "<Plug>(coc-classobj-i)")
            vim.keymap.set("o", "ic", "<Plug>(coc-classobj-i)")
            vim.keymap.set("x", "ac", "<Plug>(coc-classobj-a)")
            vim.keymap.set("o", "ac", "<Plug>(coc-classobj-a)")

            -- <C-s> 选择范围（需要 LSP 支持）
            vim.keymap.set("n", "<C-s>", "<Plug>(coc-range-select)", { silent = true })
            vim.keymap.set("x", "<C-s>", "<Plug>(coc-range-select)", { silent = true })

            -- 保存时自动格式化
            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = { "*.c", "*.cc", "*.json", "*.cpp", "*.h", "*.hpp", "*.lua", "*.cxx", "*.m", "*.mm" }, -- 你需要自动格式化的文件类型
                callback = function()
                    vim.cmd('CocCommand editor.action.formatDocument')
                end,
            })

            -- :Fold 命令折叠当前 buffer
            vim.api.nvim_create_user_command("Fold", function(opts)
                vim.fn.CocAction('fold', table.unpack(opts.fargs))
            end, { nargs = "?" })

            -- :OR 命令组织导入
            vim.api.nvim_create_user_command("OR", function()
                vim.fn.CocActionAsync('runCommand', 'editor.action.organizeImport')
            end, {})
        end
    },

}
