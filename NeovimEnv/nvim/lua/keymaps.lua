---@diagnostic disable: undefined-global

-- =======================================================================
-- [非目标功能：已注释保留]
-- termdebug gdb 中将 '-' 自动替换为结构体指针箭头 '->'
-- =======================================================================
local function buf_name_contains_gdb(bufnr)
	if type(bufnr) ~= "number" or not vim.api.nvim_buf_is_valid(bufnr) then
		return false
	end
	local name = vim.api.nvim_buf_get_name(bufnr) or ""
	return name:find("/usr/bin/gdb", 1, true) ~= nil
end

local function ensure_gdb_arrow_mapping(bufnr)
	if type(bufnr) ~= "number" or not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end
	if not buf_name_contains_gdb(bufnr) then
		return
	end

	local ok, already = pcall(vim.api.nvim_buf_get_var, bufnr, "gdb_arrow_done")
	if ok and already then
		return
	end

	local mapper = function()
		local cur = vim.api.nvim_get_current_buf()
		if cur ~= bufnr then
			return "-"
		end

		local lnum, col
		local okpos = pcall(function()
			lnum = vim.fn.line(".")
			col = vim.fn.col(".") - 1
		end)
		if not okpos or not lnum or not col then
			return "-"
		end

		local line = ""
		local okline, extracted = pcall(vim.api.nvim_buf_get_lines, cur, lnum - 1, lnum, false)
		if okline and type(extracted) == "table" then
			line = extracted[1] or ""
		end

		local prev = ""
		if col >= 1 and #line >= col then
			prev = line:sub(col, col)
		end

		if prev == "-" then
			return "-"
		end
		return "->"
	end

	vim.keymap.set({ "i", "t" }, "-", mapper, { expr = true, noremap = true, buffer = bufnr })
	pcall(vim.api.nvim_buf_set_var, bufnr, "gdb_arrow_done", true)
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufAdd", "BufWinEnter", "TermOpen", "BufReadPost" }, {
	callback = function(args)
		local bufnr = args and args.buf or vim.api.nvim_get_current_buf()
		ensure_gdb_arrow_mapping(bufnr)
	end,
})

for _, b in ipairs(vim.api.nvim_list_bufs()) do
	ensure_gdb_arrow_mapping(b)
end

-- =======================================================================
-- 标签页（Tab）与窗口流转
-- =======================================================================
-- 移动当前 buffer 到新 tab 并关闭原窗口
vim.keymap.set("n", "<leader>mt", function()
	local orig_win = vim.api.nvim_get_current_win()
	local bufnr = vim.api.nvim_get_current_buf()

	local ok, err = pcall(vim.cmd, ("tab sbuffer %d"):format(bufnr))
	if not ok then
		vim.notify("移动 buffer 到新 tab 失败: " .. tostring(err), vim.log.levels.ERROR)
		return
	end

	if orig_win and vim.api.nvim_win_is_valid(orig_win) then
		local cur_win = vim.api.nvim_get_current_win()
		if orig_win ~= cur_win then
			pcall(vim.api.nvim_win_close, orig_win, true)
		end
	end
end, { desc = "移动当前 buffer 到新 Tab", noremap = true })

-- =======================================================================
-- 文件路径与重命名
-- =======================================================================
vim.keymap.set("n", "<leader>cp", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	vim.notify("已复制完整路径: " .. path, vim.log.levels.INFO)
end, { desc = "复制完整文件路径到剪贴板" })

local function RenameInPlace()
	local oldname = vim.fn.expand("%:t")
	local dir = vim.fn.expand("%:p:h")
	local newname = vim.fn.input("重命名为: ", oldname)
	if newname == "" or newname == oldname then
		vim.notify("重命名已取消", vim.log.levels.INFO)
		return
	end
	local oldfile = dir .. "/" .. oldname
	local newfile = dir .. "/" .. newname
	local ok, err = os.rename(oldfile, newfile)
	if ok then
		vim.cmd("edit " .. vim.fn.fnameescape(newfile))
		vim.cmd("silent! bwipeout #")
		vim.notify("重命名成功: " .. newname, vim.log.levels.INFO)
	else
		vim.notify("重命名失败! " .. (err or "未知错误"), vim.log.levels.ERROR)
	end
end
vim.keymap.set("n", "<space>rn", RenameInPlace, { desc = "原地重命名当前文件" })

-- =======================================================================
-- 视图显示与段落折叠（文本/笔记优化）
-- =======================================================================
local function ToggleLineNumbers()
	vim.wo.relativenumber = not vim.wo.relativenumber
	if vim.wo.relativenumber then
		vim.wo.number = true
	end
end
vim.keymap.set("n", "<space>aa", ToggleLineNumbers, { silent = true, desc = "切换行号显示状态" })

-- 快速折叠空行之间的自然段落（Markdown 与 LaTeX 极为实用）
vim.keymap.set("n", "<space>zf", "?^\\s*$<CR>jV/^\\s*$/-1<CR>zf", { silent = true, desc = "折叠当前自然段落" })

-- =======================================================================
-- Buffer 与多窗口交互
-- =======================================================================
vim.keymap.set(
	"n",
	"<space>bb",
	":buffers<cr>:buffer ",
	{ noremap = true, desc = "列出并输入编号切换 Buffer" }
)
vim.keymap.set("n", "<space>bn", "<C-^>", { noremap = true, desc = "轮换到上一个活跃 Buffer" })
vim.keymap.set("n", "<space>e", ":tabnew ", { noremap = true, desc = "新建 Tab" })
vim.keymap.set("n", "<space>vs", ":lefta vs ", { noremap = true, desc = "在左侧新建垂直分屏" })
vim.keymap.set("n", "<space>vw", ":vnew<CR>", { silent = true, desc = "垂直新建空白窗口" })
vim.keymap.set("n", "<space>sp", ":belowright sp ", { noremap = true, desc = "在下方新建水平分屏" })
vim.keymap.set("n", "<space>sw", ":belowright new<CR>", { silent = true, desc = "在下方水平新建空白窗口" })
vim.keymap.set(
	"n",
	"<space>nw",
	':vnew<CR>:normal! "*p<CR>',
	{ noremap = true, desc = "新建窗口并粘贴剪贴板内容" }
)
vim.keymap.set("n", "<space>br", "<C-w>r", { silent = true, desc = "顺时针旋转分屏窗口" })
vim.keymap.set("n", "<space>w", ":w<cr>", { noremap = true, desc = "快速保存当前文件" })
vim.keymap.set("n", "<space>dt", function()
	if vim.wo.diff then
		vim.cmd("diffoff!")
		vim.notify("Diff 对比已关闭", vim.log.levels.INFO)
	else
		vim.cmd("windo diffthis")
		vim.notify("Diff 对比已开启", vim.log.levels.INFO)
	end
end, { noremap = true, desc = "一键切换所有分屏 Diff 对比" })

-- 智能关闭窗口或清除无用缓冲区
local function smart_close()
	local bufname = vim.fn.expand("%:t")
	if bufname:match("%.exe$") then
		vim.cmd("bdelete")
	else
		vim.cmd("quit")
	end
end
vim.keymap.set("n", "<space>q", smart_close, { silent = true, desc = "智能关闭窗口或缓冲区" })

-- =======================================================================
-- 窗口方向切换（支持 Normal 模式与 Insert 模式）
-- =======================================================================
local win_move_keymaps = {
	{ "n", "<C-l>", "<C-w>l", "光标切至右侧窗口" },
	{ "n", "<C-h>", "<C-w>h", "光标切至左侧窗口" },
	{ "n", "<C-j>", "<C-w>j", "光标切至下方窗口" },
	{ "n", "<C-k>", "<C-w>k", "光标切至上方窗口" },
	{ "i", "<C-l>", "<C-o><C-w>l", "插入模式切至右侧窗口" },
	{ "i", "<C-h>", "<C-o><C-w>h", "插入模式切至左侧窗口" },
	{ "i", "<C-j>", "<C-o><C-w>j", "插入模式切至下方窗口" },
	{ "i", "<C-k>", "<C-o><C-w>k", "插入模式切至上方窗口" },
}

for _, v in ipairs(win_move_keymaps) do
	vim.keymap.set(v[1], v[2], v[3], { silent = true, desc = v[4] })
end

-- =======================================================================
-- 窗口尺寸平滑调整
-- =======================================================================
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { silent = true, desc = "增加窗口高度" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { silent = true, desc = "减少窗口高度" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { silent = true, desc = "减少窗口宽度" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { silent = true, desc = "增加窗口宽度" })

-- =======================================================================
-- 高效移动、退出与软折行导航（大篇幅笔记必配）
-- =======================================================================
vim.keymap.set("i", "jf", "<esc>", { desc = "快速退回 Normal 模式" })
vim.keymap.set("c", "jf", "<c-c>", { desc = "命令行快速取消退出" })

-- 软换行（wrap）时按视觉行上下移动，避免直接跨越大段文字
vim.keymap.set("n", "j", "gj", { noremap = true, silent = true, desc = "按视觉行下移" })
vim.keymap.set("n", "k", "gk", { noremap = true, silent = true, desc = "按视觉行上移" })
vim.keymap.set("n", "^", "g^", { desc = "移动到视觉行首" })
vim.keymap.set("n", "H", "^", { desc = "行首第一个非空字符" })
vim.keymap.set("n", "L", "g_", { desc = "行尾最后一个非空字符" })
vim.keymap.set("n", "J", "gJ", { desc = "合并下行（不追加空格）" })
vim.keymap.set("n", "gf", "gF", { desc = "跳转至文件并自动定位行号" })

vim.keymap.set("n", "<space><space>", "<C-f>", { desc = "向下快速翻页" })
vim.keymap.set("n", "<Tab>", "gt", { noremap = true, desc = "切换至下一个 Tab" })

-- =======================================================================
-- 剪贴板与智能粘贴
-- =======================================================================
-- 使用专用寄存器避免覆盖刚刚删除/复制的内容
local paste_keymaps = {

	-- 只粘贴最近一次用 y 复制的内容（完全忽略 d、c、x 的删除内容）
	{ "n", "p", '"0p', "粘贴最近 yank 的内容" },
	{ "x", "p", '"0p', "可视选区粘贴" },
	{ "n", "P", '"0P', "向上粘贴最近 yank 的内容" },
	{ "x", "P", '"0P', "可视选区向上粘贴" },

	-- 粘贴 dd 删掉的内容
	{ "n", "<space>p", '""p', "粘贴默认匿名寄存器内容" },
	{ "x", "<space>p", '""p', "选区粘贴默认匿名寄存器" },
	{ "n", "<space>P", '""P', "向上粘贴默认匿名寄存器" },
	{ "x", "<space>P", '""P', "选区向上粘贴默认寄存器" },
}

for _, v in ipairs(paste_keymaps) do
	vim.keymap.set(v[1], v[2], v[3], { noremap = true, desc = v[4] })
end

-- 智能粘贴系统剪贴板（行内精准拼接，不破坏后续排版）
vim.keymap.set("n", "<leader>p", function()
	if not vim.bo.modifiable then
		vim.notify("当前缓冲区处于只读状态", vim.log.levels.WARN)
		return
	end
	local plus = vim.fn.getreg("+")
	local star = vim.fn.getreg("*")
	local to_paste = plus ~= "" and plus or (star ~= "" and star or nil)
	if not to_paste then
		vim.notify("系统剪贴板为空", vim.log.levels.WARN)
		return
	end
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()
	local insert_pos = col + 1
	local before = line:sub(1, insert_pos)
	local after = line:sub(insert_pos + 1)
	local lines = vim.split(to_paste, "\n", true)
	if #lines == 1 then
		vim.api.nvim_set_current_line(before .. lines[1] .. after)
	else
		local new_lines = { before .. lines[1] }
		for i = 2, #lines - 1 do
			table.insert(new_lines, lines[i])
		end
		table.insert(new_lines, lines[#lines] .. after)
		vim.api.nvim_buf_set_lines(0, row - 1, row, false, new_lines)
	end
	vim.notify(string.format("已粘贴并插入 %d 行内容", #lines), vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = "光标后精准插入系统剪贴板内容" })

-- 复制选区或当前行至系统剪贴板（同步写入 + 和 * 寄存器）
local function copy_to_clipboard()
	local mode = vim.fn.mode()
	local lines_copied = 1
	if mode == "v" or mode == "V" or mode == "\22" then
		vim.cmd('normal! "+y')
		local copied = vim.fn.getreg("+")
		local lines = vim.split(copied, "\n", { plain = true, trimempty = true })
		lines_copied = vim.tbl_count(lines)
	else
		vim.cmd('normal! "+yy')
	end
	vim.fn.setreg("*", vim.fn.getreg("+"))
	vim.notify(string.format("已复制 %d 行至系统剪贴板", lines_copied), vim.log.levels.INFO)
end
vim.keymap.set(
	{ "n", "v" },
	"<leader>y",
	copy_to_clipboard,
	{ noremap = true, silent = true, desc = "复制至系统剪贴板" }
)

-- 复制整篇文档内容
vim.keymap.set("n", "<space>ac", function()
	vim.cmd("%y+")
	vim.cmd("%y*")
	vim.notify("已复制整篇文件内容至剪贴板", vim.log.levels.INFO)
end, { desc = "全选并复制整篇文档" })

-- =======================================================================
-- Vimdiff（与剪贴板快速比对文本）
-- =======================================================================
vim.keymap.set("n", "<leader>df", function()
	local filename = vim.fn.expand("%:t:r")
	local ext = vim.fn.expand("%:e")
	local dir = vim.fn.expand("%:p:h")
	local diff_file = string.format("%s/%s_diff.%s", dir, filename, ext)
	vim.cmd("vs " .. vim.fn.fnameescape(diff_file))
	local plus = vim.fn.getreg("+")
	local star = vim.fn.getreg("*")
	local to_paste = {}
	if plus == star then
		to_paste = vim.split(plus, "\n", true)
	else
		vim.list_extend(to_paste, vim.split(plus, "\n", true))
		vim.list_extend(to_paste, vim.split(star, "\n", true))
	end
	local bufnr = vim.api.nvim_get_current_buf()
	local line_count = vim.api.nvim_buf_line_count(bufnr)
	vim.api.nvim_buf_set_lines(bufnr, 0, line_count, false, {})
	vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, to_paste)
	vim.cmd("diffthis")
	vim.cmd("wincmd p")
	vim.cmd("diffthis")
end, { desc = "创建临时分屏并与剪贴板内容进行 Diff 对比" })

-- =======================================================================
-- 内置终端
-- =======================================================================
vim.keymap.set("n", "<space>tt", ":belowright vertical terminal<CR>", { desc = "在右侧垂直打开终端" })

-- =======================================================================
-- Quickfix 列表控制（LaTeX 编译报错、全局搜索排查必备）
-- =======================================================================
vim.keymap.set(
	"n",
	"<space>co",
	":belowright copen<CR>",
	{ noremap = true, silent = true, desc = "打开 Quickfix 列表" }
)
vim.keymap.set("n", "<space>cq", ":cclose<CR>", { noremap = true, silent = true, desc = "关闭 Quickfix 列表" })
vim.keymap.set(
	"n",
	"<space>cj",
	":cnext<CR>zz",
	{ noremap = true, silent = true, desc = "跳转至下一个错误/结果并居中" }
)
vim.keymap.set(
	"n",
	"<space>ck",
	":cprev<CR>zz",
	{ noremap = true, silent = true, desc = "跳转至上一个错误/结果并居中" }
)

-- =======================================================================
-- [非目标功能：已注释保留]
-- C/C++ 专用编译与运行函数及快捷键
-- =======================================================================
-- local function compile_and_run_c()
-- 	vim.cmd("write")
-- 	local src = vim.fn.expand("%:p")
-- 	local filename = vim.fn.expand("%:t:r")
-- 	local dir = vim.fn.expand("%:p:h")
-- 	local ext = vim.fn.expand("%:e")
-- 	local out = dir .. "/" .. filename .. ".out"
-- 	local compiler = ext == "c" and "gcc" or "g++"
-- 	local std_flag = ext == "c" and "-std=c17" or "-std=c++17"
-- 	local cmd = string.format('%s -g %s "%s" -o "%s" 2>&1', compiler, std_flag, src, out)
-- 	local result = vim.fn.systemlist(cmd)
-- 	if vim.v.shell_error == 0 then
-- 		vim.cmd("vsplit | terminal " .. out)
-- 		vim.cmd("startinsert")
-- 	else
-- 		local items = {}
-- 		for _, line in ipairs(result) do
-- 			local fname, lnum, col, text = string.match(line, "^([^:]+):(%d+):(%d+):%s*(.*)")
-- 			if fname and lnum and col then
-- 				table.insert(items, {
-- 					filename = fname,
-- 					lnum = tonumber(lnum),
-- 					col = tonumber(col),
-- 					text = text,
-- 				})
-- 			elseif #line > 0 then
-- 				table.insert(items, {
-- 					filename = src,
-- 					lnum = 1,
-- 					col = 1,
-- 					text = line,
-- 				})
-- 			end
-- 		end
-- 		vim.fn.setqflist({}, " ", { title = "编译错误", items = items })
-- 		vim.cmd("vert copen")
-- 		vim.cmd("vertical resize " .. math.floor(vim.o.columns / 2))
-- 		vim.notify("编译失败！错误已显示在 quickfix 窗口", vim.log.levels.ERROR)
-- 	end
-- end
-- vim.keymap.set("n", "<F1>", compile_and_run_c, { noremap = true, silent = true, desc = "编译并运行 C/C++" })
