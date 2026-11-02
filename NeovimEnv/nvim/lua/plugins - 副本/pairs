---@diagnostic disable: undefined-global
return {

	-- =========================
	-- mini.pairs：自动补全括号/引号
	-- =========================
	{
		"echasnovski/mini.pairs",
		event = "InsertEnter",
		config = function()
			local ok, pairs = pcall(require, "mini.pairs")
			if not ok then
				return
			end

			pairs.setup({
				mappings = {
					["("] = { action = "open", pair = "()", neigh_pattern = "[^\\].", register = { cr = false } },
					["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\].", register = { cr = false } },
					["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\].", register = { cr = false } },

					[")"] = { action = "close", pair = "()", neigh_pattern = "[^\\]." },
					["]"] = { action = "close", pair = "[]", neigh_pattern = "[^\\]." },
					["}"] = { action = "close", pair = "{}", neigh_pattern = "[^\\]." },

					['"'] = { action = "closeopen", pair = '""', neigh_pattern = "[^\\].", register = { cr = false } },
					["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^\\].", register = { cr = false } },
					["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^\\].", register = { cr = false } },
				},
			})

			-- 回车处理：在成对括号之间插入空行并缩进
			vim.keymap.set("i", "<CR>", function()
				local row, col = unpack(vim.api.nvim_win_get_cursor(0))
				local line = vim.api.nvim_get_current_line()
				-- note: row is 1-indexed, col is 0-indexed
				local char_before = line:sub(col, col)
				local char_after = line:sub(col + 1, col + 1)

				local pairs_map = { ["{"] = "}", ["("] = ")", ["["] = "]" }

				if pairs_map[char_before] and char_after == pairs_map[char_before] then
					-- split line at cursor
					local before_line = line:sub(1, col)
					local after_line = line:sub(col + 1)

					-- compute existing indent of the before_line (tabs or spaces)
					local indent_str = before_line:match("^(%s*)") or ""
					local add
					if vim.bo.expandtab then
						add = string.rep(" ", vim.bo.shiftwidth)
					else
						add = "\t"
					end

					-- 替换当前行并插入两行（空缩进行 + 包含闭合部分的行）
					local buf = vim.api.nvim_get_current_buf()
					vim.api.nvim_buf_set_lines(buf, row - 1, row, false, {
						before_line,
						indent_str .. add,
						indent_str .. after_line,
					})

					-- 把光标移动到那一空行的缩进位置，进入插入模式
					vim.api.nvim_win_set_cursor(0, { row + 1, #indent_str + #add })
					return ""
				else
					-- 不是成对括号之间，回退到默认回车行为
					local cr = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
					vim.api.nvim_feedkeys(cr, "n", false)
					return ""
				end
			end, { noremap = true, silent = true })
		end,
	},

	-- =========================
	-- tpope/vim-repeat：让 . 可以重复更多 plugin 操作
	-- =========================
	-- {
	-- 	"tpope/vim-repeat",
	-- 	lazy = true,
	-- },

	-- =========================
	-- mini.surround：替代 nvim-surround 的 surround 功能（添加/删除/替换环绕）
	-- =========================
	{
		"echasnovski/mini.surround",
		-- dependencies = { "tpope/vim-repeat" }, -- 保持与原 plugin 的 repeat 行为，以支持 . 重复
		keys = {
			{ "ys", mode = { "n", "x" }, desc = "添加包裹" }, -- operator-pending（n）和 visual（x）
			{ "ds", mode = "n", desc = "删除包裹" },
			{ "cs", mode = "n", desc = "更改包裹" },
		},
		config = function()
			require("mini.surround").setup({
				mappings = {
					add = "ys", -- 添加环绕（operator-pending / visual 都支持）
					delete = "ds", -- 删除环绕
					replace = "cs", -- 替换环绕
				},
			})
		end,
	},
}
