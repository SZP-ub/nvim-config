---@diagnostic disable: undefined-global
vim.opt.autoindent = true
vim.opt.cindent = false
vim.cmd("filetype indent off") -- 禁用文件类型缩进冲突

vim.g.mapleader = "\\"
-- vim.g.maplocalleader = "\\"

vim.opt.compatible = false
vim.opt.wrap = true
vim.cmd("syntax enable")
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"
vim.opt.errorbells = false
vim.opt.visualbell = true
vim.opt.wildmenu = true
vim.opt.wildmode = { "list:longest", "full" }
vim.opt.wildignorecase = true
vim.opt.cursorline = true
vim.opt.helplang = "cn"

vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
-- vim.opt.smartcase = true
vim.opt.backspace = { "indent", "eol", "start" }
vim.opt.updatetime = 100
vim.opt.scrolloff = 2
-- vim.opt.guifont = "Maple Mono NF Medium:h18:i"
-- vim.opt.linespace = 3 -- 行距微调
vim.opt.ttyfast = true
vim.opt.lazyredraw = true
vim.opt.synmaxcol = 501

-- 重新打开文件时恢复上次光标位置
vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        if vim.fn.line([['"]]) > 0 and vim.fn.line([['"]]) <= vim.fn.line("$") then
            vim.cmd('normal! g`"')
        end
    end,
})

vim.g.markdown_recommended_style = 0
vim.g.c_no_curly_error = 1

-- 自动保存
vim.opt.autowrite = true
vim.api.nvim_create_autocmd("FocusLost", { command = "silent! wa" })
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, { command = "silent! update" })
vim.opt.updatetime = 600000

-- Tab 设置
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- 设置补全菜单高度和宽度，减少遮挡
vim.o.pumheight = 8
vim.o.pumwidth = 30
vim.o.pumblend = 0 -- 约等于透明度0.7

-- 新插入的窗口布局
vim.opt.splitbelow = true
vim.opt.splitright = true

-- ======================== 背景 =================
vim.o.background = "dark"
-- vim.o.background = "light"
-- vim.cmd("colorscheme snazzy")
vim.cmd("colorscheme peachpuff")
-- vim.cmd("colorscheme habamax")

-- ========================行号===================

-- 只在绝对行号和相对行号之间切换
function ToggleLineNumbers()
    if vim.wo.relativenumber then
        vim.wo.relativenumber = false
    else
        vim.wo.relativenumber = true
        vim.wo.number = true
    end
end

-- 绑定快捷键 <space>aa 到切换行号函数
vim.keymap.set("n", "<space>aa", ToggleLineNumbers, { silent = true, desc = "切换行号显示" })

-- ======================折叠=======================

-- <space>zf 折叠整个段落但不包含末尾空行
vim.keymap.set(
    "n",
    "<space>zf",
    "?^\\s*$<CR>jV/^\\s*$/-1<CR>zf",
    { silent = true, desc = "折叠段落（不含末尾空行）" }
)

-- 保存和恢复折叠叠状态
vim.api.nvim_create_augroup("remember_folds", { clear = true })
vim.api.nvim_create_autocmd("BufWinLeave", {
    group = "remember_folds",
    callback = function()
        if vim.bo.buftype == "" and vim.fn.bufname("%") ~=
            "" then
            vim.cmd("mkview")
        end
    end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
    group = "remember_folds",
    callback = function()
        if vim.bo.buftype == "" and vim.fn.bufname("%") ~=
            "" then
            vim.cmd("silent! loadview")
        end
    end,
})

-- FoldRange 命令
vim.api.nvim_create_user_command("FoldRange", function(opts)
    local args = table.concat(opts.fargs, " ")
    if string.match(args, "%s") then
        vim.cmd(substitute(args, "%s+", ",", "g") .. "fold")
    else
        vim.cmd(args .. "fold")
    end
end, { nargs = "+" })

-- <leader>zf 绑定 FoldRange 命令（可根据你的 leader 键修改）
vim.keymap.set("n", "<leader>zf", ":FoldRange ", { noremap = true })

-- ======================== vim-signature ============================
-- 标记高亮组
vim.g.SignatureMarkTextHL = 'Search'
-- marker 高亮组
vim.g.SignatureMarkerTextHL = 'WarningMsg'

-- 是否在行号栏显示标记
vim.g.SignatureIncludeMarkers = '!"#$%&\'()*+,-./:;<=>?@[\\]^_`'

-- 是否显示快捷键提示
-- vim.g.SignatureMap = 1

-- C-o of stack
vim.o.jumpoptions = "stack"

-- =========vim原生mark配置=========

-- 获取一个字符（类似 getchar）
local function get_char_str()
    local ok, c = pcall(vim.fn.getchar)
    if not ok then
        return ""
    end
    if type(c) == "number" then
        if c == 27 then
            return "<Esc>"
        elseif c == 13 then
            return "<CR>"
        else
            return vim.fn.nr2char(c)
        end
    end
    return c
end

-- mark 处理函数
local function mark_sequence_handler()
    local char1 = get_char_str()
    if char1 == "m" then
        vim.api.nvim_echo({ { "m", "Special" } }, false, {})
        local char2 = get_char_str()
        if char2:match("^[a-z]$") then
            vim.cmd("normal! m" .. char2:upper())
            vim.api.nvim_echo({ { "\r", "None" } }, false, {})
            vim.api.nvim_echo({ { "Global mark '" .. char2:upper() .. "' set", "MoreMsg" } }, false, {})
            vim.cmd("silent! SignatureRefresh")
        elseif char2 == "<Esc>" then
            vim.api.nvim_echo({ { "\r", "None" } }, false, {})
        else
            vim.api.nvim_echo({ { "\rInvalid mark letter. Use a-z", "ErrorMsg" } }, false, {})
        end
    elseif char1:match("^[a-zA-Z]$") then
        vim.cmd("normal! m" .. char1)
        vim.cmd("silent! SignatureRefresh")
    elseif char1 == "<Esc>" then
        -- 什么也不做
    else
        vim.api.nvim_echo({ { "Invalid mark letter. Use a-zA-Z", "ErrorMsg" } }, false, {})
    end
end

-- 绑定快捷键 m 到 mark_sequence_handler
vim.keymap.set("n", "m", mark_sequence_handler, { silent = true, desc = "Mark Sequence Handler" })

-- ==================== Termdebug =================
vim.g.termdebug_config = {
    -- command = 'gdb',           -- 调试器命令
    -- map_K = false,             -- 禁用K键映射
    -- map_minus = false,         -- 禁用-键映射
    -- map_plus = false,          -- 禁用+键映射
    -- popup = 0,                 -- 禁用弹出菜单
    -- winbar = 0,                -- 禁用窗口工具条
    wide = 63,         -- 设置窗口宽度
    use_prompt = true, -- 使用提示模式
    -- disasm_window = true,      -- 显示汇编窗口
    -- variables_window = true,   -- 显示变量窗口
    -- sign = '>>',               -- 断点符号
    sign_decimal = 1, -- 以十进制来显示断点标号
    -- disasm_window_height = 15, -- 汇编窗口高度
    -- variables_window_height = 15, -- 变量窗口高度
    -- evaluate_in_popup = true,  -- 弹窗显示计算结果
}

-- =================重命名文件===================
local function linux_rename_in_place()
    local oldname = vim.fn.expand("%:t")
    local dir = vim.fn.expand("%:p:h")
    local newname = vim.fn.input("Rename to: ", oldname)
    if newname == "" or newname == oldname then
        vim.api.nvim_echo({ { "重命名已取消", "None" } }, false, {})
        return
    end
    local oldfile = dir .. "/" .. oldname
    local newfile = dir .. "/" .. newname
    -- 使用 mv 命令重命名
    vim.fn.system({ "mv", oldfile, newfile })
    if vim.fn.filereadable(newfile) == 1 then
        vim.cmd("edit " .. vim.fn.fnameescape(newfile))
        vim.cmd("silent! bwipeout #")
    else
        vim.api.nvim_err_writeln("重命名失败! 文件未创建: " .. newfile)
    end
end

vim.keymap.set("n", "<leader>rn", linux_rename_in_place, { desc = "重命名当前文件" })

-- ========== 重构粘贴复制 ==========

-- 将 p/P 映射为粘贴复制寄存器 ("0) 的内容
for _, mode in ipairs({ "n", "v" }) do
    vim.keymap.set(mode, "p", '""p', { noremap = true })
    vim.keymap.set(mode, "P", '""P', { noremap = true })
    vim.keymap.set(mode, "<space>p", '"0p', { noremap = true })
    -- 系统剪贴板专用粘贴
    vim.keymap.set(mode, "<leader>p", '"*p', { noremap = true })
    vim.keymap.set(mode, "<leader>P", '"*P', { noremap = true })
end

-- 复制到系统粘贴板
local function copy_to_clipboard()
    local mode = vim.fn.mode()
    local lines_copied = 1
    if mode == 'v' or mode == 'V' or mode == '\22' then
        -- 可视模式或有选区时复制选区
        vim.cmd('normal! "+y')
        local start_line = vim.fn.line("v")
        local end_line = vim.fn.line(".")
        lines_copied = math.abs(end_line - start_line) + 1
    else
        -- 否则复制当前行
        vim.cmd('normal! "+yy')
    end
    vim.fn.setreg('*', vim.fn.getreg('+'))
    local msg = string.format("Copied %d line%s to system clipboard!", lines_copied, lines_copied > 1 and "s" or "")
    vim.api.nvim_echo({ { msg, "Comment" } }, false, {})
    vim.defer_fn(function()
        vim.api.nvim_echo({ { "" } }, false, {})
        vim.cmd("redraw")
    end, 500) -- 反馈存在 1 秒
end
vim.keymap.set({ 'n', 'v' }, '<leader>y', copy_to_clipboard, { noremap = true, silent = true })

-- 插入模式粘贴
vim.keymap.set("i", "<C-p>", "<C-r>0", { noremap = true })

--============复制整个文件到剪切板=============
vim.keymap.set("n", "<space>ac", function()
    vim.cmd("%y+")
    vim.cmd("%y*")
    vim.api.nvim_echo({ { "Copied entire file to clipboard!", "None" } }, false, {})
end, { desc = "复制整个文件到剪贴板（+ 和 *）" })

-- =================智能q====================
local function smart_close()
    local bufname = vim.fn.expand("%:t")
    if bufname:match("%.exe$") then
        vim.cmd("bdelete")
    else
        vim.cmd("quit")
    end
end

vim.keymap.set("n", "<space>q", smart_close, { silent = true, desc = "智能关闭窗口或缓冲区" })

--============窗口快捷切换================
-- 水平窗口切换（左右方向）
vim.keymap.set("n", "<C-l>", "<C-w>l", { silent = true })
vim.keymap.set("n", "<C-h>", "<C-w>h", { silent = true })
vim.keymap.set("i", "<C-l>", "<C-o><C-w>l", { silent = true })
vim.keymap.set("i", "<C-h>", "<C-o><C-w>h", { silent = true })

-- 垂直窗口切换（上下方向）
vim.keymap.set("n", "<C-j>", "<C-w>j", { silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { silent = true })
vim.keymap.set("i", "<C-j>", "<C-o><C-w>j", { silent = true })
vim.keymap.set("i", "<C-k>", "<C-o><C-w>k", { silent = true })

-- ===================== 键位映射 ====================
-- 高效退出键
vim.keymap.set("i", "jf", "<esc>")
vim.keymap.set("c", "jf", "<c-c>")
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")
vim.keymap.set("n", "^", "g^")
vim.keymap.set("n", "gf", "gF")
vim.keymap.set("n", "J", "gJ")

-- 空格键前缀命令
vim.keymap.set("n", "<space>ww", ":buffers<cr>:buffer ", { noremap = true })
vim.keymap.set("n", "<space>e", ":tabnew ", { noremap = true })
vim.keymap.set("n", "<space>vs", ":lefta vs ", { noremap = true })
vim.keymap.set("n", "<space>w", ":w<cr>", { noremap = true })
-- vim.keymap.set("n", "<space>q", ":q<cr>", { noremap = true })
-- vim.keymap.set("n", "<space>qq", ":bd<CR>", { noremap = true })
vim.keymap.set("n", "<space>bb", "<C-^>", { noremap = true })
vim.keymap.set("n", "<Space>vw", ":vnew<CR>", { silent = true })
vim.keymap.set("n", "<space>nw", ':vnew<CR>:normal! "*p<CR>', { noremap = true })
vim.keymap.set("n", "<Space>wr", "<C-w>r", { silent = true })
vim.keymap.set("n", "<Space>wrr", "<C-w>R", { silent = true })
vim.keymap.set("n", "<space>df", ":diffthis<CR>", { noremap = true })

-- ctrl组合键
-- Ctrl+e 在插入模式下向右移动光标
vim.keymap.set("i", "<C-e>", "<Right>", { noremap = true, silent = true })

-- Quickfix 窗口快捷键映射
vim.keymap.set("n", "<Space>co", ":belowright copen<CR>", { noremap = true })
vim.keymap.set("n", "<Space>cc", ":cclose<CR>", { noremap = true })
vim.keymap.set("n", "<Space>cn", ":cnext<CR>zz", { noremap = true })
vim.keymap.set("n", "<Space>cp", ":cprev<CR>zz", { noremap = true })


-- ============== nvim-tree ====================

vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

vim.keymap.set('n', '<leader>t', ':belowright vertical terminal<CR>')

-- ===========禁用备份文件=====================
vim.opt.swapfile = false
-- 禁用备份文件，避免部分语言服务器出错
vim.opt.backup = false
vim.opt.writebackup = false
-- 总是显示 signcolumn，避免诊断信息出现时文本左右跳动
vim.opt.signcolumn = "yes"

-- =============== 文件: init.lua 或 lua/plugins.lua ===============
require("config.lazy")

-- 文件: init.lua 或 lua/plugins.lua
-- require("config.lazy").setup({
--     { "stevearc/aerial.nvim" },                -- 代码结构大纲
--     { "tyru/caw.vim" },                        -- 注释插件
--     { "lukas-reineke/indent-blankline.nvim" }, -- 缩进线
--     { "folke/lazy.nvim" },                     -- 插件管理器本身
--     -- { "onsails/lspkind.nvim" },                -- 补全图标
--     { "nvim-lualine/lualine.nvim" },           -- 状态栏
--     -- { "bufferline.nvim" },     -- 顶部状态栏
--     -- { "williamboman/mason.nvim" },             -- LSP/DAP/Linter 管理
--     { "echasnovski/mini.pairs" },          -- 自动补全括号
--     { "kylechui/nvim-surround" },          -- 包围符操作
--     { "nvim-tree/nvim-tree.lua" },         -- 文件树
--     { "nvim-treesitter/nvim-treesitter" }, -- 语法高亮
--     -- { "nvim-treesitter/nvim-treesitter-textobjects" }, -- treesitter 文本对象
--     -- { "nvim-tree/nvim-web-devicons" },         -- 文件图标
--     { "romainl/vim-cool" },                -- 搜索高亮消除
--     { "kshenoy/vim-signature" },           -- mark 管理
--     { "yianwillis/vimcdoc" },              -- 中文文档
--     { "HiPhish/rainbow-delimiters.nvim" }, -- 彩虹括号
--     { "neoclide/coc.nvim" },               -- 智能补全
--     {"mhinz/vim-startify"},                -- 启动页管理
--     {"OXY2DEV/markviwe.nvim"}              -- markdown预览
--     {"nvim-tree/nvim-web-devicons"}        -- 图标
--     {"h-hg/fcitx.nvim"},                   --
-- })
