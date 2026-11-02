---@diagnostic disable: undefined-global

-- ============ termdebug gdb 中 '-' 替换为 '->' ==============
local function buf_name_contains_gdb(bufnr)
	if type(bufnr) ~= "number" then
		return false
	end
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return false
	end
	local name = vim.api.nvim_buf_get_name(bufnr) or ""
	-- 以包含字符串 "/usr/bin/gdb" 作为判定条件（能匹配 term://.../usr/bin/gdb）
	return name:find("/usr/bin/gdb", 1, true) ~= nil
end

local function ensure_gdb_arrow_mapping(bufnr)
	-- 参数校验
	if type(bufnr) ~= "number" then
		return
	end
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end
	if not buf_name_contains_gdb(bufnr) then
		return
	end

	-- 避免重复设置：用 buffer 变量做标记
	local ok, already = pcall(vim.api.nvim_buf_get_var, bufnr, "gdb_arrow_done")
	if ok and already then
		return
	end

	-- 映射闭包：安全地读取行/列，失败时退回普通 '-'
	local mapper = function()
		-- 确保当前 buffer 就是我们要绑定的 buffer
		local cur = vim.api.nvim_get_current_buf()
		if cur ~= bufnr then
			return "-" -- 非目标 buffer 时不替换
		end

		-- 尝试读取光标位置与当前行，所有读取都用 pcall 以免报错
		local lnum, col
		local okpos, _ = pcall(function()
			lnum = vim.fn.line(".")
			col = vim.fn.col(".") - 1 -- 0-based: 表示光标前的字符索引
		end)
		if not okpos or not lnum or not col then
			return "-" -- 无法获取位置则保守地返回 '-'
		end

		local line
		local okline, extracted = pcall(vim.api.nvim_buf_get_lines, cur, lnum - 1, lnum, false)
		if okline and type(extracted) == "table" then
			line = extracted[1] or ""
		else
			line = ""
		end

		local prev = ""
		if col >= 1 and #line >= col then
			prev = line:sub(col, col)
		end

		-- 如果前一个字符已经是 '-'（连续输入 --），则插入普通 '-'
		if prev == "-" then
			return "-"
		end

		-- 默认把单独的 '-' 展开为 '->'
		return "->"
	end

	-- 为 Insert 模式 和 Terminal 模式 设置 buffer-local 的 expr 映射
	-- 注意：expr = true 表示 key 被按下时会插入 mapper() 返回的字符串
	vim.keymap.set({ "i", "t" }, "-", mapper, { expr = true, noremap = true, buffer = bufnr })

	-- 标记已设置
	pcall(vim.api.nvim_buf_set_var, bufnr, "gdb_arrow_done", true)
end

-- 在这些事件触发时尝试为符合条件的 buffer 添加映射（覆盖打开、切换、term 打开等场景）
vim.api.nvim_create_autocmd({ "BufEnter", "BufAdd", "BufWinEnter", "TermOpen", "BufReadPost" }, {
	callback = function(args)
		local bufnr = args and args.buf
		if not bufnr or type(bufnr) ~= "number" then
			bufnr = vim.api.nvim_get_current_buf()
		end
		ensure_gdb_arrow_mapping(bufnr)
	end,
})

-- 启动时扫描已存在的 buffer（如果已打开 term://.../usr/bin/gdb，会立即绑定）
for _, b in ipairs(vim.api.nvim_list_bufs()) do
	ensure_gdb_arrow_mapping(b)
end

-- =============== Remove buffer to new_tab =================
-- 可选：仅当没有设置 vim.g.mapleader 时才设为默认（不会覆盖用户已有的 leader）
if vim.g.mapleader == nil then
	vim.g.mapleader = " "
end

vim.keymap.set("n", "<leader>mt", function()
	-- 记录原窗口与 buffer
	local orig_win = vim.api.nvim_get_current_win()
	local bufnr = vim.api.nvim_get_current_buf()

	-- 在新 tab 中直接打开当前 buffer（不会先创建空白 buffer）
	local ok, err = pcall(vim.cmd, ("tab sbuffer %d"):format(bufnr))
	if not ok then
		vim.notify("移动 buffer 到新 tab 失败: " .. tostring(err), vim.log.levels.ERROR)
		return
	end

	-- 关闭原来的窗口（如果仍然有效且不是当前窗口）
	if orig_win and vim.api.nvim_win_is_valid(orig_win) then
		local cur_win = vim.api.nvim_get_current_win()
		if orig_win ~= cur_win then
			-- 第二个参数 true 表示强制关闭（不提示保存）
			pcall(vim.api.nvim_win_close, orig_win, true)
		end
	end
end, { desc = "移动当前 buffer 到新 tab 并关闭原先显示该 buffer 的窗口", noremap = true })

-- ==================== 复制完整文件路径 =====================
vim.keymap.set("n", "<leader>cp", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	print("file:", path)
end, { desc = "复制完整文件路径到剪贴板" })

-- ==================== 移动行/选区上下 =====================
-- local move_opts = { desc = "Move line/selection" }
-- vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", vim.tbl_extend("force", move_opts, { desc = "Move line down" }))
-- vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", vim.tbl_extend("force", move_opts, { desc = "Move line up" }))
-- vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", vim.tbl_extend("force", move_opts, { desc = "Move selection down" }))
-- vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", vim.tbl_extend("force", move_opts, { desc = "Move selection up" }))

-- ==================== 行号切换 ====================
local function ToggleLineNumbers()
	vim.wo.relativenumber = not vim.wo.relativenumber
	if vim.wo.relativenumber then
		vim.wo.number = true
	end
end
vim.keymap.set("n", "<space>aa", ToggleLineNumbers, { silent = true, desc = "切换行号显示" })

-- ==================== 折叠段落 ====================
vim.keymap.set(
	"n",
	"<space>zf",
	"?^\\s*$<CR>jV/^\\s*$/-1<CR>zf",
	{ silent = true, desc = "折叠段落（不含末尾空行）" }
)

-- ==================== buffer切换 ====================
vim.keymap.set("n", "<space>bb", ":buffers<cr>:buffer ", { noremap = true, desc = "列出并切换buffer" })
vim.keymap.set("n", "<space>e", ":tabnew ", { noremap = true, desc = "新建tab" })
vim.keymap.set("n", "<space>vs", ":lefta vs ", { noremap = true, desc = "左侧垂直分屏" })
vim.keymap.set("n", "<space>w", ":w<cr>", { noremap = true, desc = "保存文件" })
vim.keymap.set("n", "<space>bn", "<C-^>", { noremap = true, desc = "切换到上一个buffer" })
vim.keymap.set("n", "<Space>vw", ":vnew<CR>", { silent = true, desc = "新建垂直窗口" })
vim.keymap.set("n", "<space>nw", ':vnew<CR>:normal! "*p<CR>', { noremap = true, desc = "新建窗口并粘贴" })
vim.keymap.set("n", "<Space>br", "<C-w>r", { silent = true, desc = "窗口旋转" })
-- vim.keymap.set("n", "<Space>brr", "<C-w>R", { silent = true, desc = "窗口反向旋转" })
vim.keymap.set("n", "<space>df", ":diffthis<CR>", { noremap = true, desc = "当前窗口加入diff" })

-- ==================== 智能关闭窗口或缓冲区 ====================
local function smart_close()
	local bufname = vim.fn.expand("%:t")
	if bufname:match("%.exe$") then
		vim.cmd("bdelete")
	else
		vim.cmd("quit")
	end
end
vim.keymap.set("n", "<space>q", smart_close, { silent = true, desc = "智能关闭窗口或缓冲区" })

-- ==================== 水平窗口切换 ====================
local win_move_keymaps = {
	-- 普通模式
	{ "n", "<C-l>", "<C-w>l", "右移窗口" },
	{ "n", "<C-h>", "<C-w>h", "左移窗口" },
	-- 插入模式
	{ "i", "<C-l>", "<C-o><C-w>l", "插入模式右移窗口" },
	{ "i", "<C-h>", "<C-o><C-w>h", "插入模式左移窗口" },
}

for _, v in ipairs(win_move_keymaps) do
	vim.keymap.set(v[1], v[2], v[3], { silent = true, desc = v[4] })
end

-- ==================== 垂直窗口切换 ====================
local win_move_v_keymaps = {
	-- 普通模式
	{ "n", "<C-j>", "<C-w>j", "下移窗口" },
	{ "n", "<C-k>", "<C-w>k", "上移窗口" },
	-- 插入模式
	{ "i", "<C-j>", "<C-o><C-w>j", "插入模式下移窗口" },
	{ "i", "<C-k>", "<C-o><C-w>k", "插入模式上移窗口" },
}

for _, v in ipairs(win_move_v_keymaps) do
	vim.keymap.set(v[1], v[2], v[3], { silent = true, desc = v[4] })
end

-- ==================== 高效退出键 ====================
vim.keymap.set("i", "jf", "<esc>", { desc = "插入模式退出" })
vim.keymap.set("c", "jf", "<c-c>", { desc = "命令模式退出" })
vim.keymap.set("n", "j", "gj", { noremap = true, silent = true, desc = "下移（软换行）" })
vim.keymap.set("n", "k", "gk", { noremap = true, silent = true, desc = "上移（软换行）" })
vim.keymap.set("n", "^", "g^", { desc = "行首（软换行）" })
vim.keymap.set("n", "gf", "gF", { desc = "跳转到文件并定位行" })
vim.keymap.set("n", "J", "gJ", { desc = "连接行（软换行）" })
vim.keymap.set("n", "H", "^", { desc = "行首" })
vim.keymap.set("n", "L", "g_", { desc = "行尾（软换行）" })
vim.keymap.set("n", "<space><space>", "<C-f>", { desc = "向下翻页" })
vim.keymap.set("n", "<Tab>", "gt", { noremap = true })

-- ==================== ctrl组合键 ====================
local misc_keymaps = {
	-- 普通模式窗口大小调整
	{ "n", "<C-Up>", ":resize +2<CR>", {}, "增加窗口高度" },
	{ "n", "<C-Down>", ":resize -2<CR>", {}, "减少窗口高度" },
	{ "n", "<C-Left>", ":vertical resize -2<CR>", {}, "减少窗口宽度" },
	{ "n", "<C-Right>", ":vertical resize +2<CR>", {}, "增加窗口宽度" },
}

for _, v in ipairs(misc_keymaps) do
	local options = vim.tbl_extend("force", v[4], { desc = v[5] })
	vim.keymap.set(v[1], v[2], v[3], options)
end

-- ===================== 终端窗口 ==========================
vim.keymap.set("n", "<space>tt", ":belowright vertical terminal<CR>", { desc = "右侧打开终端" })

-- ==================== 重命名文件 ====================
local function RenameInPlace()
	local oldname = vim.fn.expand("%:t")
	local dir = vim.fn.expand("%:p:h")
	local newname = vim.fn.input("Rename to: ", oldname)
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
vim.keymap.set("n", "<space>rn", RenameInPlace, { desc = "重命名当前文件" })

-- ==================== 重构粘贴复制 ====================
local paste_keymaps = {
	-- 普通模式、可视模式往下方粘贴
	{ "n", "p", '"0p', "普通粘贴" },
	{ "x", "p", '"0p', "可视模式粘贴" },
	{ "n", "P", '"0P', "普通粘贴到上方" },
	{ "x", "P", '"0P', "可视模式粘贴到上方" },

	-- 使用最近复制内容
	{ "n", "<space>p", '""p', "粘贴最近一次复制内容" },
	{ "x", "<space>p", '""p', "可视模式粘贴最近一次复制内容" },
	{ "n", "<space>P", '""P', "粘贴最近一次复制内容到上方" },
	{ "x", "<space>P", '""P', "可视模式粘贴最近一次复制内容到上方" },
}

for _, v in ipairs(paste_keymaps) do
	vim.keymap.set(v[1], v[2], v[3], { noremap = true, desc = v[4] })
end

-- ==================== 智能粘贴系统剪贴板内容到光标位置 ====================
vim.keymap.set("n", "<leader>p", function()
	if not vim.bo.modifiable then
		vim.notify("当前 buffer 不可编辑", vim.log.levels.WARN)
		return
	end
	local plus = vim.fn.getreg("+")
	local star = vim.fn.getreg("*")
	local to_paste = plus ~= "" and plus or (star ~= "" and star or nil)
	if not to_paste then
		vim.notify("剪贴板为空", vim.log.levels.WARN)
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
	vim.notify(string.format("共插入 %d 行", #lines), vim.log.levels.INFO)
end, { noremap = true, silent = true, desc = "智能粘贴系统剪贴板内容到光标后一位（保持格式）" })

-- ==================== 复制到系统剪贴板 ====================
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
	local msg = string.format("Copied %d line%s to system clipboard!", lines_copied, lines_copied > 1 and "s" or "")
	vim.notify(msg, vim.log.levels.INFO)
	vim.defer_fn(function()
		vim.notify("", vim.log.levels.INFO)
		vim.cmd("redraw")
	end, 1000)
end
vim.keymap.set(
	{ "n", "v" },
	"<leader>y",
	copy_to_clipboard,
	{ noremap = true, silent = true, desc = "复制到系统剪贴板" }
)

-- ==================== 复制整个文件到剪贴板 ====================
vim.keymap.set("n", "<space>ac", function()
	vim.cmd("%y+")
	vim.cmd("%y*")
	vim.notify("Copied entire file to clipboard!", vim.log.levels.INFO)
end, { desc = "复制整个文件到剪贴板（+ 和 *）" })

-- ==================== vimdiff ====================
vim.keymap.set("n", "<leader>vd", function()
	local fullpath = vim.fn.expand("%:p")
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
end, { desc = "新建diff buffer并粘贴剪贴板内容进行diff" })

-- ==================== 编译运行 ====================
local function compile_and_run_c()
	vim.cmd("write")
	local src = vim.fn.expand("%:p")
	local filename = vim.fn.expand("%:t:r")
	local dir = vim.fn.expand("%:p:h")
	local ext = vim.fn.expand("%:e")
	local out = dir .. "/" .. filename .. ".out"
	local compiler = ext == "c" and "gcc" or "g++"
	local std_flag = ext == "c" and "-std=c17" or "-std=c++17"
	local cmd = string.format('%s -g %s "%s" -o "%s" 2>&1', compiler, std_flag, src, out)
	local result = vim.fn.systemlist(cmd)
	if vim.v.shell_error == 0 then
		vim.cmd("vsplit | terminal " .. out)
		vim.cmd("startinsert")
	else
		local items = {}
		for _, line in ipairs(result) do
			local fname, lnum, col, text = string.match(line, "^([^:]+):(%d+):(%d+):%s*(.*)")
			if fname and lnum and col then
				table.insert(items, {
					filename = fname,
					lnum = tonumber(lnum),
					col = tonumber(col),
					text = text,
				})
			elseif #line > 0 then
				table.insert(items, {
					filename = src,
					lnum = 1,
					col = 1,
					text = line,
				})
			end
		end
		vim.fn.setqflist({}, " ", { title = "编译错误", items = items })
		vim.cmd("vert copen")
		vim.cmd("vertical resize " .. math.floor(vim.o.columns / 2))
		vim.notify("编译失败！错误已显示在 quickfix 窗口", vim.log.levels.ERROR)
	end
end
vim.keymap.set("n", "<F1>", compile_and_run_c, { noremap = true, silent = true, desc = "编译并运行C/C++文件" })

-- ==================== Quickfix 窗口快捷键映射 ====================
vim.keymap.set(
	"n",
	"<Space>co",
	":belowright copen<CR>",
	{ noremap = true, silent = true, desc = "打开 quickfix 窗口" }
)
vim.keymap.set("n", "<Space>cq", ":cclose<CR>", { noremap = true, silent = true, desc = "关闭 quickfix 窗口" })
vim.keymap.set(
	"n",
	"<Space>cj",
	":cnext<CR>zz",
	{ noremap = true, silent = true, desc = "跳转到下一个 quickfix 项" }
)
vim.keymap.set(
	"n",
	"<Space>ck",
	":cprev<CR>zz",
	{ noremap = true, silent = true, desc = "跳转到上一个 quickfix 项" }
)
