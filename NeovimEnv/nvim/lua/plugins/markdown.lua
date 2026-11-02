---@diagnostic disable: undefined-global
return {
	{
		"OXY2DEV/markview.nvim",
		lazy = false,
		priority = 100,
		config = function()
			local markview = require("markview")

			markview.setup({
				preview = {
					auto_start = true,
					icon_provider = "devicons",
				},

				bullets = {
					enabled = true,
					icons = { "●", "○", "◆", "◇" },
					ordered = function(ctx)
						local value = vim.trim(ctx.value)
						local index = tonumber(value:sub(1, #value - 1))
						return ("%d."):format(index > 1 and index or ctx.index)
					end,
				},

				checkboxes = {
					enabled = true,
					unchecked = {
						icon = "󰄱 ",
					},
					checked = {
						icon = "󰱒 ",
					},
					custom = {
						todo = {
							raw = "[-]",
							rendered = "󰥔 ",
						},
					},
				},

				quote = {
					enabled = true,
					icon = "▋",
				},

				links = {
					enabled = true,
				},

				callouts = {
					enabled = true,
					styles = {
						note = { icon = "󰋽 " },
						tip = { icon = "󰌶 " },
						important = { icon = "󰅾 " },
						warning = { icon = "󰀪 " },
						caution = { icon = "󰳦 " },
						info = { icon = "󰋽 " },
						success = { icon = "󰄬 " },
						danger = { icon = "󱐌 " },
						error = { icon = "󱐌 " },
						bug = { icon = "󰨰 " },
						quote = { icon = "󱆨 " },
						example = { icon = "󰉹 " },
					},
				},

				anti_conceal = {
					enabled = true,
					ignore = {
						code_background = true,
						sign = true,
					},
				},
			})

			-- ==========================================
			-- Obsidian 日语振假名 (Furigana) 终端内联渲染
			-- ==========================================
			local ns = vim.api.nvim_create_namespace("obsidian_furigana")

			local function render_furigana(bufnr)
				bufnr = bufnr or vim.api.nvim_get_current_buf()
				if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= "markdown" then
					return
				end

				-- 确保开启 conceal 隐藏符号
				vim.opt_local.conceallevel = 2

				vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
				local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

				for row, line in ipairs(lines) do
					local init = 1
					while true do
						-- 匹配 {汉字|假名} 格式
						local s, e, kanji, ruby = line:find("%{([^|}]+)|([^}]+)%}", init)
						if not s then
							break
						end

						-- 将 お|の 拼接为 おの
						local kana = ruby:gsub("|", "")
						local pipe_idx = s + #kanji

						-- 1. 隐藏开头的 '{'
						pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, row - 1, s - 1, {
							end_col = s,
							conceal = "",
						})

						-- 2. 隐藏 '|假名}' 部分
						pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, row - 1, pipe_idx, {
							end_col = e,
							conceal = "",
						})

						-- 3. 在其后内联附加显示淡灰色的 (假名)
						pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, row - 1, e, {
							virt_text = { { " (" .. kana .. ")", "Comment" } },
							virt_text_pos = "inline",
						})

						init = e + 1
					end
				end
			end

			-- 自动监听 Markdown 文件的进入与修改事件
			vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "InsertLeave" }, {
				pattern = "*.md",
				callback = function(args)
					render_furigana(args.buf)
				end,
			})
		end,
	},

	{
		"dhruvasagar/vim-table-mode",
		lazy = true,
		keys = {
			{ "<leader>tm", "<cmd>TableModeToggle<cr>", desc = "开关表格模式" },
			{ "<leader>tr", "<cmd>TableModeRealign<cr>", desc = "全表重新对齐" },
			{ "<leader>tt", desc = "文本转表格 (默认逗号分隔)", mode = { "n", "v" } },
			{ "<leader>tT", desc = "文本转表格 (自定义输入分隔符)", mode = { "n", "v" } },
			{ "]|", desc = "跳转到右侧下一个单元格", mode = { "n" } },
			{ "[|", desc = "跳转到左侧上一个单元格", mode = { "n" } },
			{ "}|", desc = "跳转到正下方单元格", mode = { "n" } },
			{ "{|", desc = "跳转到正上方单元格", mode = { "n" } },
			{ "<leader>tdd", desc = "删除当前行", mode = { "n" } },
			{ "<leader>tdc", desc = "删除当前列", mode = { "n" } },
			{ "<leader>ti", desc = "在当前位置插入新列", mode = { "n" } },
			{ "<leader>tic", desc = "插入新列 (备用映射)", mode = { "n" } },
			{ "<leader>ts", desc = "按当前列内容对表格进行排序", mode = { "n" } },
			{ "<leader>t?", desc = "显示当前单元格行列坐标 (如 r2c3)", mode = { "n" } },
			{ "<leader>tfa", desc = "为当前行/列添加公式", mode = { "n" } },
			{ "<leader>tfe", desc = "执行公式求值并更新数值", mode = { "n" } },
		},
		init = function()
			vim.g.table_mode_corner = "|"
			vim.g.table_mode_corner_corner = "|"
			vim.g.table_mode_header_fillchar = "-"
			vim.g.table_mode_auto_align = 1
			vim.g.table_mode_syntax = 1
			vim.g.table_mode_map_prefix = "<leader>t"
			vim.g.table_mode_toggle_map = "m"
			vim.g.table_mode_tableize_map = "<leader>tt"
			vim.g.table_mode_tableize_d_map = "<leader>tT"
		end,
	},

	{
		"whitestarrain/md-section-number.nvim",
		lazy = false,
		config = function()
			local md_num = require("md_section_number")

			md_num.setup({
				max_level = 5,
				min_level = 2,
				ignore_pairs = {
					{ "```", "```" },
					{ "<!--", "-->" },
				},
				toc = {
					width = 30,
					position = "right",
					indent_space_number = 2,
					header_prefix = "- ",
				},
			})

			vim.api.nvim_create_user_command("MdUpdateNumber", md_num.update_heading_number, { desc = "自动编号" })
			vim.api.nvim_create_user_command("MdClearNumber", md_num.clear_heading_number, { desc = "清除编号" })
			vim.api.nvim_create_user_command("MdTocToggle", md_num.toggle_toc, { desc = "切换大纲" })

			vim.keymap.set("n", "<leader>mn", "<cmd>MdUpdateNumber<cr>", { desc = "Markdown: 自动排号" })
			vim.keymap.set("n", "<leader>mc", "<cmd>MdClearNumber<cr>", { desc = "Markdown: 清除序号" })
			vim.keymap.set("n", "<leader>mt", "<cmd>MdTocToggle<cr>", { desc = "Markdown: 切换大纲" })
		end,
	},

	-- {
	-- 	"reybits/scratch.nvim",
	-- 	lazy = true,
	-- 	keys = {
	-- 		{ "<leader>bs", "<cmd>ScratchTask<cr>", desc = "打开/切换浮动草稿本" },
	-- 		{ "<leader>bS", "<cmd>ScratchToggle<cr>", desc = "在新分割窗口中打开草稿" },
	-- 	},
	-- 	cmd = {
	-- 		"Scratch",
	-- 		"ScratchSplit",
	-- 	},
	-- 	opts = {
	--
	-- 		title = "Scratch",
	-- 		border = "rounded",
	-- 		width = 0.6,
	-- 		height = 0.6,
	--
	-- 		-- enable per-project notes
	-- 		local_notes = true,
	--
	-- 		-- enable global notes
	-- 		global_notes = true,
	--
	-- 		-- per-project directory holding the note and the issues
	-- 		local_dir = ".scratch",
	--
	-- 		-- close the window when the focus leaves it
	-- 		close_on_leave = true,
	--
	-- 		-- window-local options (vim.wo)
	-- 		win_opts = {
	-- 			wrap = true,
	-- 			linebreak = true,
	-- 			cursorline = true,
	-- 		},
	--
	-- 		window = {
	-- 			border = "rounded",
	-- 			width = 0.8,
	-- 			height = 0.8,
	-- 			blend = 0,
	-- 		},
	-- 		filetype = "markdown",
	-- 		persist = true,
	-- 		auto_save = false,
	-- 		keymaps = {
	-- 			close = { "q", "<Esc>" },
	-- 		},
	-- 	},
	-- 	config = function(_, opts)
	-- 		local ok, scratch = pcall(require, "scratch")
	-- 		if ok then
	-- 			scratch.setup(opts)
	-- 		end
	-- 	end,
	-- },
}
