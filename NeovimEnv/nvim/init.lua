---@diagnostic disable: undefined-global

local opt = vim.opt
local g = vim.g
local api = vim.api

-----------------------------------------------------------------------
-- Leader 键设置（必须在加载任何插件之前优先声明）
-----------------------------------------------------------------------
g.mapleader = "\\"

-----------------------------------------------------------------------
-- Windows PowerShell / 外部 Shell 环境适配
-----------------------------------------------------------------------
local is_pwsh = vim.fn.executable("pwsh") == 1
local shell_cmd = is_pwsh and "pwsh" or "powershell"

opt.shell = shell_cmd
opt.shellcmdflag =
	"-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';"
opt.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
opt.shellpipe = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
opt.shellquote = ""
opt.shellxquote = ""

-----------------------------------------------------------------------
-- 基础缩进与折叠策略
-----------------------------------------------------------------------
opt.autoindent = true -- 新行继承上一行缩进
opt.cindent = false -- 关闭 C 风格自动缩进
vim.cmd("filetype indent off") -- 不使用默认 filetype 缩进脚本，自主控制

opt.foldmethod = "expr" -- 使用表达式折叠
-- Neovim 0.10+ 推荐内置原生 foldexpr，同时兼顾 Treesitter
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99 -- 默认展开所有折叠

-----------------------------------------------------------------------
-- 显示、窗口与渲染外观
-----------------------------------------------------------------------
opt.number = true -- 显示绝对行号
opt.relativenumber = true -- 显示相对行号
opt.cursorline = true -- 高亮当前光标所在行
opt.termguicolors = true -- 启用 24-bit RGB 真彩色
opt.signcolumn = "yes" -- 始终显示左侧标志栏，杜绝界面晃动
-- opt.mouse = "a" -- 全模式启用鼠标支持
opt.mouse = "" -- 全模式启用鼠标支持
vim.g.neovide_hide_mouse_when_typing = true -- 输入时隐藏鼠标
opt.showmode = false -- 底部状态栏已显示模式，关闭默认提示文本
opt.breakindent = true -- 折行后保持与上一行相同的缩进层次
opt.scrolloff = 3 -- 垂直滚动时光标上下至少保留 3 行边界
opt.synmaxcol = 501 -- 语法高亮最大列数，超长单行自动跳过以保障流畅度
vim.g.neovide_refresh_rate = 120 -- 刷新率60
vim.g.neovide_refresh_rate_idle = 120 -- 空闲刷新率60
vim.g.neovide_no_idle = true -- 窗口重绘
vim.g.neovide_profiler = false -- 显示帧率
vim.g.neovide_cursor_antialiasing = true -- 抗锯齿
vim.g.neovide_cursor_animate_in_insert_mode = true -- 插入模式动画

-- 标记与渲染隐藏（对 Markview、Obsidian、LaTeX 渲染至关重要）
opt.conceallevel = 2 -- 折叠隐藏标记字符并以漂亮图标替代
opt.concealcursor = "nc" -- 在 Normal 和 Command 模式下生效隐藏

-- 字体设置
-- opt.guifont = "Maple Mono NF CN Medium Italic:h14"
opt.guifont = "Maple Mono NF CN:h14:b:i" -- 全局字体设置
vim.api.nvim_set_hl(0, "Comment", { italic = true }) -- 让注释（Comment）显示为斜体
vim.api.nvim_set_hl(0, "Keyword", { bold = true, italic = true }) -- 让关键字（Keyword，如 local, function, return 等）显示为粗体或斜体
vim.g.neovide_scale_factor = 1.22 -- 全局 UI / 字体缩放比例（默认 1.0）

vim.opt.linespace = 3 -- 调整行间距（使用 Neovim 原生选项，必须是整数像素，默认 0）

-- 分屏方向
opt.splitbelow = true -- 水平分割新建窗口在下方
opt.splitright = true -- 垂直分割新建窗口在右侧

-----------------------------------------------------------------------
-- 文件行为、安全与备份
-----------------------------------------------------------------------
opt.swapfile = false -- 禁用 swap 文件
opt.backup = false -- 禁用备份文件
opt.writebackup = false -- 禁用写入过程中的临时备份
opt.confirm = true -- 未保存直接退出时弹出交互式确认
opt.errorbells = false -- 关闭错误提示音
opt.visualbell = false -- 关闭视觉提示闪烁
opt.helplang = "cn" -- 优先加载中文帮助文档

-----------------------------------------------------------------------
-- 搜索与替换
-----------------------------------------------------------------------
opt.hlsearch = true -- 保持搜索结果高亮
opt.incsearch = true -- 增量搜索（输入字符时实时匹配跳转）
opt.ignorecase = true -- 搜索默认忽略字母大小写
opt.smartcase = true -- 若检索词包含大写字母，自动转为精确大小写匹配
opt.inccommand = "nosplit" -- 行内替换命令（:s）进行实时预览，不新建预览窗口

-----------------------------------------------------------------------
-- 补全与命令行交互
-----------------------------------------------------------------------
opt.wildignorecase = true -- 命令行路径/指令补全忽略大小写
opt.wildmenu = true -- 启用增强型命令行补全
opt.wildmode = "longest:full,full" -- 补全填充行为
opt.wildoptions = "pum" -- 命令行以浮动弹出菜单展示选项

opt.pumheight = 8 -- 浮动补全菜单最大显示行数
opt.pumwidth = 30 -- 浮动补全菜单最小宽度
opt.pumblend = 0 -- 补全菜单不透明度

-----------------------------------------------------------------------
-- 键入延迟与按键行为
-----------------------------------------------------------------------
opt.backspace = { "indent", "eol", "start" } -- 允许 Backspace 跨行跨缩进平滑删除
opt.updatetime = 100 -- CursorHold 触发延迟（ms），提升代码诊断响应速度
opt.timeout = true -- 必须开启按键序列超时检测
opt.timeoutlen = 7000 -- 多键映射序列（如 Leader 快捷键）的最大等待毫秒数
opt.lazyredraw = false -- 运行宏或批处理命令时暂停屏幕重绘，提升执行效率

-----------------------------------------------------------------------
-- 缩进与制表符规范
-----------------------------------------------------------------------
opt.tabstop = 4 -- 制表符显示宽度为 4
opt.shiftwidth = 4 -- 缩进换算宽度为 4
opt.expandtab = true -- Tab 键自动展开为空格
opt.smartindent = true -- 开启智能缩进

-----------------------------------------------------------------------
-- 文件类型扩展映射
-----------------------------------------------------------------------
-- 现代标准方法：将 *.h 默认识别为 C 语言头文件
vim.filetype.add({
	extension = {
		h = "c",
	},
})

-----------------------------------------------------------------------
-- Markdown 专属换行与渲染优化
-----------------------------------------------------------------------
opt.wrap = true -- 全局默认开启自动换行
g.markdown_recommended_style = 0 -- 禁用 Neovim 强制覆盖的 Markdown 缩进设定

api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	desc = "Markdown 专属配置与渲染",
	callback = function()
		vim.opt_local.wrap = false -- 笔记编写时关闭硬折行
		vim.opt_local.conceallevel = 2 -- 确保满足 Obsidian/Markview 渲染层级要求
		vim.cmd("silent! Markview render")
	end,
})

-----------------------------------------------------------------------
-- 终端窗口始终不可覆盖
-----------------------------------------------------------------------
api.nvim_create_autocmd("TermOpen", {
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		-- vim.wo.winfixbuf = true -- 锁定终端窗口，强制外部文件在其他窗口打开
	end,
})

-----------------------------------------------------------------------
-- 终端模式交互键位
-----------------------------------------------------------------------
-- 终端中按下 Esc 退回 Normal 模式
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true, desc = "终端退出输入态" })

-- fzf.vim 终端窗口特殊处理：按 Esc 直接中断退出窗口
api.nvim_create_autocmd("FileType", {
	pattern = "fzf",
	desc = "fzf 弹窗内 Esc 直接关闭",
	callback = function()
		vim.keymap.set("t", "<Esc>", "<C-c>", { buffer = true, silent = true })
	end,
})

-----------------------------------------------------------------------
-- 主题与界面高亮
-----------------------------------------------------------------------
-- opt.background = "dark"
-- vim.cmd("syntax enable")
-- vim.cmd("colorscheme peachpuff")

-- 自定义可视选区高亮（橙色底色，突出当前选中区域）
api.nvim_set_hl(0, "Visual", { bg = "#f5c195", fg = "NONE" })

-- 复制时高亮闪烁提示
api.nvim_set_hl(0, "YankHighlight", { bg = "#cccccc", fg = "NONE" })
api.nvim_create_autocmd("TextYankPost", {
	desc = "复制内容闪烁提示",
	group = api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank({ higroup = "YankHighlight", timeout = 500 })
	end,
})

-----------------------------------------------------------------------
-- C 测试框架配置 (vim-test / ultest)
-----------------------------------------------------------------------
g.c_no_curly_error = 0
g.ultest_deprecation_notice = 0
g["test#c#runner"] = "custom_c"
g["test#custom_c#file_pattern"] = "test_.*\\.c$"
g["test#custom_c#command"] = "cd test && ./test_runner"

-----------------------------------------------------------------------
-- Godbolt 汇编预览窗口辅助显示
-----------------------------------------------------------------------
api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
	pattern = "*",
	desc = "Godbolt 汇编无文件缓冲强制启用行号",
	callback = function()
		if vim.bo.filetype == "asm" and vim.bo.buftype == "nofile" then
			vim.wo.number = true
		end
	end,
})

-----------------------------------------------------------------------
-- termdebug 交互式调试器适配
-----------------------------------------------------------------------
vim.cmd("packadd termdebug")

g.termdebug_config = {
	command = "gdb", -- 调试器可执行文件
	winbar = 0, -- 禁用窗口工具栏
	wide = 163, -- 主窗口分屏触发宽度阈值
	variables_window = true, -- 自动显示变量监视窗口
	variables_window_height = 9, -- 变量监视窗口行高
	sign_decimal = 1, -- 断点使用十进制编号展示
	evaluate_in_popup = true, -- 悬停表达式弹窗求值
}

-- 自动重排 Termdebug 窗口布局
api.nvim_create_autocmd("User", {
	pattern = "TermdebugStartPost",
	desc = "Termdebug 调试窗口布局重排",
	callback = function()
		local win_ids = api.nvim_list_wins()
		local win2, win3, win4 = win_ids[2], win_ids[3], win_ids[4]
		if not (win2 and win3 and win4) then
			vim.notify("Termdebug 窗口数量不足，跳过重排", vim.log.levels.WARN)
			return
		end

		-- 用窗口 4 的 buffer 替换窗口 2，随后关闭窗口 4
		local buf4 = api.nvim_win_get_buf(win4)
		api.nvim_win_set_buf(win2, buf4)
		api.nvim_win_close(win4, true)

		-- 交换窗口 2 与窗口 3 的 buffer
		local buf2 = api.nvim_win_get_buf(win2)
		local buf3 = api.nvim_win_get_buf(win3)
		api.nvim_win_set_buf(win2, buf3)
		api.nvim_win_set_buf(win3, buf2)

		-- 窗口 2 高度折半压缩
		local cur_height = api.nvim_win_get_height(win2)
		if cur_height > 1 then
			api.nvim_win_set_height(win2, math.max(1, math.floor(cur_height / 2)))
		end

		-- 焦点切换至 win2 底部输出，最后停留在 win3 代码窗口
		api.nvim_set_current_win(win2)
		vim.cmd("normal! G")
		api.nvim_set_current_win(win3)
	end,
})

-----------------------------------------------------------------------
-- 外部插件与扩展模块加载
-----------------------------------------------------------------------
g.vimtex_disable_version_check = 1

require("keymaps")
require("config.lazy")
