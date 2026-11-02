---@diagnostic disable: undefined-global
return {
	-- =========================
	-- mini.pairs：自动补全括号/引号/数学环境
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

			-- 成对符号间智能回车展开
			vim.keymap.set("i", "<CR>", function()
				local row, col = unpack(vim.api.nvim_win_get_cursor(0))
				local line = vim.api.nvim_get_current_line()
				local char_before = line:sub(col, col)
				local char_after = line:sub(col + 1, col + 1)

				local pairs_map = { ["{"] = "}", ["("] = ")", ["["] = "]" }

				if pairs_map[char_before] and char_after == pairs_map[char_before] then
					local before_line = line:sub(1, col)
					local after_line = line:sub(col + 1)

					local indent_str = before_line:match("^(%s*)") or ""
					local add = vim.bo.expandtab and string.rep(" ", vim.bo.shiftwidth) or "\t"

					local buf = vim.api.nvim_get_current_buf()
					vim.api.nvim_buf_set_lines(buf, row - 1, row, false, {
						before_line,
						indent_str .. add,
						indent_str .. after_line,
					})

					vim.api.nvim_win_set_cursor(0, { row + 1, #indent_str + #add })
					return ""
				else
					local cr = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
					vim.api.nvim_feedkeys(cr, "n", false)
					return ""
				end
			end, { noremap = true, silent = true })
		end,
	},

	-- =========================
	-- mini.surround：快捷添加/替换环绕符
	-- =========================
	{
		"echasnovski/mini.surround",
		keys = {
			{ "ys", mode = { "n", "x" }, desc = "添加包裹" },
			{ "ds", mode = "n", desc = "删除包裹" },
			{ "cs", mode = "n", desc = "更改包裹" },
		},
		config = function()
			require("mini.surround").setup({
				mappings = {
					add = "ys",
					delete = "ds",
					replace = "cs",
				},
			})
		end,
	},
}