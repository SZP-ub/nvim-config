---@diagnostic disable: undefined-global
return {

    {
        "neoclide/coc.nvim",
        branch = "release",
        config = function()
            -- K 显示文档
            local function show_doc()
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
                -- Tab：补全菜单可见时选择下一个，否则跳转/展开 snippet，否则插入 Tab 或刷新补全
                "coc#pum#visible() ? coc#pum#next(1) : coc#expandableOrJumpable() ? '<C-r>=coc#rpc#request(\"doKeymap\", [\"snippets-expand-jump\",\"\"])<CR>' : v:lua.check_back_space() ? '<Tab>' : coc#refresh()",
                { noremap = true, silent = true, expr = true })

            -- Shift-Tab：补全菜单可见时选择上一个，否则 snippet 跳转，否则插入 Shift-Tab
            vim.api.nvim_set_keymap("i", "<S-Tab>",
                "coc#pum#visible() ? coc#pum#prev(1) : coc#jumpable(-1) ? '<C-r>=coc#rpc#request(\"doKeymap\", [\"snippets-expand-jump-back\",\"\"])<CR>' : '<S-Tab>'",
                { noremap = true, silent = true, expr = true })

            -- 回车键确认补全项，否则用 mini.pairs 处理
            vim.keymap.set("i", "<CR>", function()
                if vim.fn['coc#pum#visible']() == 1 then
                    return vim.fn['coc#pum#confirm']()
                else
                    return require("mini.pairs").cr()
                end
            end, { expr = true, silent = true, noremap = true })

            -- <C-Space> 触发补全
            vim.keymap.set("i", "<C-Space>", "coc#refresh()", { expr = true, silent = true })

            -- [g 和 ]g 跳转诊断信息
            vim.keymap.set("n", "[g", "<Plug>(coc-diagnostic-prev)", { silent = true }) -- 跳转到上一个诊断
            vim.keymap.set("n", "]g", "<Plug>(coc-diagnostic-next)", { silent = true }) -- 跳转到下一个诊断

            -- 跳转到定义/类型定义/实现/引用
            vim.keymap.set("n", "gd", "<Plug>(coc-definition)", { silent = true })      -- 跳转到定义
            vim.keymap.set("n", "gy", "<Plug>(coc-type-definition)", { silent = true }) -- 跳转到类型定义
            vim.keymap.set("n", "gi", "<Plug>(coc-implementation)", { silent = true })  -- 跳转到实现
            vim.keymap.set("n", "gr", "<Plug>(coc-references)", { silent = true })      -- 查找引用

            -- K 显示文档
            vim.keymap.set("n", "K", show_doc, { silent = true }) -- 悬浮显示文档

            -- 光标悬停时高亮符号及引用
            vim.api.nvim_create_autocmd("CursorHold", {
                pattern = "*",
                callback = function()
                    vim.fn.CocActionAsync('highlight')
                end,
            })

            -- 重命名符号
            vim.keymap.set("n", "<leader>rn", "<Plug>(coc-rename)", { silent = true })             -- 重命名
            -- 选区代码操作
            vim.keymap.set("x", "<leader>a", "<Plug>(coc-codeaction-selected)", { silent = true }) -- 选区代码操作
            vim.keymap.set("n", "<leader>a", "<Plug>(coc-codeaction-selected)", { silent = true }) -- 选区代码操作
            -- 光标处代码操作
            vim.keymap.set("n", "<leader>ac", "<Plug>(coc-codeaction-cursor)", { silent = true })  -- 光标处代码操作
            -- 整个 buffer 代码操作
            vim.keymap.set("n", "<leader>as", "<Plug>(coc-codeaction-source)", { silent = true })  -- buffer 代码操作
            -- 当前行诊断快速修复
            vim.keymap.set("n", "<leader>qf", "<Plug>(coc-fix-current)", { silent = true })        -- 快速修复

            -- 重构操作
            vim.keymap.set("n", "<leader>re", "<Plug>(coc-codeaction-refactor)", { silent = true })         -- 重构
            vim.keymap.set("x", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true }) -- 选区重构
            vim.keymap.set("n", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true }) -- 选区重构

            -- 运行当前行的 Code Lens
            vim.keymap.set("n", "<leader>cl", "<Plug>(coc-codelens-action)", { silent = true }) -- CodeLens

            -- 函数/类文本对象映射
            local objs = { { "f", "funcobj" }, { "c", "classobj" } }
            -- 遍历对象类型（函数和类）
            for _, obj in ipairs(objs) do
                -- 视觉模式下，选择“函数/类内部”文本对象（如 if、ic）
                vim.keymap.set("x", "i" .. obj[1], "<Plug>(coc-" .. obj[2] .. "-i)") -- 内部函数/类
                -- 操作符等待模式下，选择“函数/类内部”文本对象（如 dif、vic）
                vim.keymap.set("o", "i" .. obj[1], "<Plug>(coc-" .. obj[2] .. "-i)")
                -- 视觉模式下，选择“函数/类外部（含自身）”文本对象（如 af、ac）
                vim.keymap.set("x", "a" .. obj[1], "<Plug>(coc-" .. obj[2] .. "-a)") -- 外部函数/类
                -- 操作符等待模式下，选择“函数/类外部（含自身）”文本对象（如 daf、vac）
                vim.keymap.set("o", "a" .. obj[1], "<Plug>(coc-" .. obj[2] .. "-a)")
            end

            -- <C-s> 选择范围
            vim.keymap.set("n", "<C-s>", "<Plug>(coc-range-select)", { silent = true }) -- 选择范围
            vim.keymap.set("x", "<C-s>", "<Plug>(coc-range-select)", { silent = true })

            -- 保存时自动格式化
            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = { "*.c", "*.cc", "*.json", "*.cpp", "*.h", "*.hpp", "*.lua", "*.cxx", "*.m", "*.mm" },
                callback = function()
                    vim.cmd('CocCommand editor.action.formatDocument') -- 保存时自动格式化
                end,
            })

            -- :Fold 命令折叠当前 buffer
            vim.api.nvim_create_user_command("Fold", function(opts)
                vim.fn.CocAction('fold', table.unpack(opts.fargs)) -- 折叠代码
            end, { nargs = "?" })

            -- :OR 命令组织导入
            vim.api.nvim_create_user_command("OR", function()
                vim.fn.CocActionAsync('runCommand', 'editor.action.organizeImport') -- 组织导入
            end, {})

            -- ccls 专用命令和快捷键
            --             local ccls_cmds = {
            --                 Derived = { "$ccls/inheritance", { derived = true }, "查找派生类" },
            --                 Base = { "$ccls/inheritance", nil, "查找基类" },
            --                 VarAll = { "$ccls/vars", nil, "查找所有变量" },
            --                 VarLocal = { "$ccls/vars", { kind = 1 }, "查找局部变量" },
            --                 VarArg = { "$ccls/vars", { kind = 4 }, "查找参数变量" },
            --                 MemberFunction = { "$ccls/member", { kind = 3 }, "查找成员函数" },
            --                 MemberType = { "$ccls/member", { kind = 2 }, "查找成员类型" },
            --                 MemberVar = { "$ccls/member", { kind = 4 }, "查找成员变量" },
            --             }
            --             for name, v in pairs(ccls_cmds) do
            --                 -- 创建命令，执行相应 ccls 查询
            --                 vim.api.nvim_create_user_command(name, function()
            --                     vim.fn.CocLocations('ccls', v[1], v[2])
            --                 end, {})
            --             end
            --
            --             -- ccls 相关快捷键
            --             vim.keymap.set('n', 'grt', '<Cmd>MemberType<CR>', { silent = true, desc = '查找成员类型（ccls）' }) -- grt 查找成员类型
            --             vim.keymap.set('n', 'grv', '<Cmd>MemberVar<CR>', { silent = true, desc = '查找成员变量（ccls）' }) -- grv 查找成员变量
            --             vim.keymap.set('n', 'gc', function()
            --                 vim.fn.CocLocations('ccls', '$ccls/call') -- gc 查找当前符号的调用者
            --             end, { silent = true, desc = '查找当前符号的调用者（Callers）' })
            --             vim.keymap.set('n', 'gcc', function()
            --                 vim.fn.CocLocations('ccls', '$ccls/call', { callee = true }) -- gcc 查找当前符号调用的函数
            --             end, { silent = true, desc = '查找当前符号调用的函数（Callees）' })
            --
        end
    },

}
