---@diagnostic disable: undefined-global
return {

	-- vim-matchup 保持原有注释
	-- {
	-- 	"andymass/vim-matchup",
	-- ...
	-- },

	-- 搜索完成停止移动时光标自动解除高亮
	{
		"romainl/vim-cool",
		keys = {
			{ "n", mode = "n", desc = "清除高亮" },
			{ "N", mode = "n", desc = "清除高亮" },
			{ "*", mode = "n", desc = "清除高亮" },
			{ "#", mode = "n", desc = "清除高亮" },
			{ "?", mode = "n", desc = "清除高亮" },
			{ "/", mode = "n", desc = "清除高亮" },
		},
	},

	-- leap.nvim：极速双字母可视跳转
	{
		url = "https://codeberg.org/andyg/leap.nvim",
		keys = {
			{ "s", mode = { "n", "x", "o" }, desc = "Leap 前向跳转" },
			{ "S", mode = { "n", "x", "o" }, desc = "Leap 后向跳转" },
			{ "gS", mode = "n", desc = "Leap 跨窗口跳转" },
		},
		config = function()
			vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)")
			vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward)")
			vim.keymap.set("n", "gS", "<Plug>(leap-from-window)")
			require("leap").opts.special_keys.next_target = "<tab>"
		end,
	},

	-- fzf 底层工具
	{
		"junegunn/fzf",
		lazy = true,
		build = "./install --bin",
	},

	-- fzf.vim：主力文本与文件快速检索
	{
		"junegunn/fzf.vim",
		dependencies = { "junegunn/fzf" },
		init = function()
			-- 1. 彻底关闭预览窗口（不再检查 bash.exe，永久消除该报错提示）
			vim.g.fzf_preview_window = {}

			-- 2. 你之前配置的 Tab / Shift-Tab 键上下切换
			vim.env.FZF_DEFAULT_OPTS = (vim.env.FZF_DEFAULT_OPTS or "")
				.. " --cycle --bind=tab:down,btab:up,shift-tab:up"
		end,
		keys = {
			{ "<space>ff", ":Files<CR>", desc = "fzf: 查找文件" },
			{ "<space>fg", ":Rg<CR>", desc = "fzf: 全文搜索 (ripgrep)" },
			{ "<space>fb", ":Buffers<CR>", desc = "fzf: 切换 Buffer" },
			{ "<space>fr", ":History<CR>", desc = "fzf: 最近打开的文件" },
			{ "<space>fm", ":Marks<CR>", desc = "fzf: 查找书签" },

			-- [非目标功能：已注释保留]
			-- { "<space>fh", ":Rg \\.h$<CR>", desc = "fzf: 查找头文件" },
			{
				"<space>fi",
				function()
					local fname = vim.fn.expand("%:t")
					vim.cmd('Rg #include "' .. fname .. '"')
				end,
				desc = "fzf: 查找包含当前文件的文件",
			},
			{ "<space>ft", ":Tags<CR>", desc = "fzf: 查找 tags" },
			{
				"grr",
				function()
					local word = vim.fn.expand("<cword>")
					vim.fn["fzf#vim#grep"](
						"rg --column --line-number --no-heading --color=always --smart-case "
							.. vim.fn.shellescape(word),
						1,
						vim.fn["fzf#vim#with_preview"]({ options = { "--query", word } }),
						0
					)
				end,
				desc = "fzf: 查找调用关系",
			},
		},
	},

	-- [非目标功能 / 避坑注释保留]
	-- fzf-lua 会在 Windows 终端发送 DSR 探针造成启动延迟与报错，由于以 fzf.vim 为主，予以注释保留

	-- {
	-- 	"ibhagwan/fzf-lua",
	-- 	lazy = true,
	-- 	dependencies = { "junegunn/fzf" },
	-- 	config = function()
	-- 		require("fzf-lua").setup({
	-- 			winopts = {
	-- 				height = 0.75,
	-- 				width = 0.70,
	-- 				row = 0.35,
	-- 				col = 0.50,
	-- 				border = "solid",
	-- 				backdrop = 60,
	-- 				fullscreen = false,
	-- 				win_hl = {
	-- 					border = "FzfLuaBorder",
	-- 					preview = "NormalFloat",
	-- 				},
	--
	-- 				preview = {
	-- 					layout = "horizontal", -- 左右分屏
	-- 					horizontal = "right:55%", -- 右侧55%为预览区
	-- 					wrap = true, -- 自动换行
	-- 					title = true, -- 关闭预览标题栏
	-- 					title_pos = "center",
	-- 					scrolloff = 0,
	-- 					delay = 20,
	-- 					scrollbar = "border", -- 滚动条在边界
	-- 					vertical = "down:45%",
	-- 					flip_columns = 100,
	-- 					winopts = {
	-- 						number = true, -- 行号（可选，fzf.vim 默认预览也是带行号）
	-- 						relativenumber = false,
	-- 						cursorline = true,
	-- 						cursorlineopt = "both",
	-- 						cursorcolumn = false,
	-- 						signcolumn = "no",
	-- 						list = false,
	-- 						foldenable = false,
	-- 						foldmethod = "manual",
	-- 						win_hl = {
	-- 							border = "FzfLuaBorder",
	-- 							preview = "NormalFloat",
	-- 						},
	-- 					},
	-- 				},
	-- 			},
	-- 			defaults = {
	-- 				multi_select = false,
	-- 				separator = "─",
	-- 			},
	-- 			grep = {
	-- 				actions = {
	-- 					["default"] = require("fzf-lua.actions").file_edit,
	-- 				},
	-- 			},
	-- 			treesitter = {
	-- 				enabled = true,
	-- 				fzf_colors = { ["hl"] = "-1:reverse", ["hl+"] = "-1:reverse" },
	-- 			},
	-- 		})
	-- 	end,
	-- },

	-- [非目标功能：已注释保留]
	-- C/C++ 专用的 cscope 调用栈分析插件
	-- {
	-- 	"dhananjaylatkar/cscope_maps.nvim",
	-- 	dependencies = { "ibhagwan/fzf-lua" },
	-- 	opts = {
	-- 		-- cscope = { db_file = "./cscope.out", picker = "quickfix", skip_picker_for_single_result = false },
	-- 		cscope = { db_file = "./cscope.out", picker = "fzf-lua", skip_picker_for_single_result = false },
	-- 		stack_view = { tree_hl = true },
	-- 	},
	-- 	keys = {
	-- 		{
	-- 			"csb", -- 谁调用了我
	-- 			function()
	-- 				vim.cmd("!cscope -Rbqkv")
	-- 			end,
	-- 			mode = "n",
	-- 			desc = "构建/更新 cscope 数据库（项目根目录）",
	-- 		},
	-- 		{
	-- 			"csn",
	-- 			function()
	-- 				local word = vim.fn.expand("<cword>")
	-- 				if word ~= nil and word ~= "" then
	-- 					vim.cmd("CsStackView open down " .. word)
	-- 				else
	-- 					vim.notify("请将光标停在有效符号上再使用调用关系树", vim.log.levels.WARN)
	-- 				end
	-- 			end,
	-- 			mode = "n",
	-- 			desc = "显示调用关系树（down）",
	-- 		},
	-- 		{
	-- 			"csu",
	-- 			function()
	-- 				local word = vim.fn.expand("<cword>")
	-- 				if word ~= nil and word ~= "" then
	-- 					vim.cmd("CsStackView open up " .. word)
	-- 				else
	-- 					vim.notify("请将光标停在有效符号上再使用调用关系树", vim.log.levels.WARN)
	-- 				end
	-- 			end,
	-- 			mode = "n",
	-- 			desc = "显示被调用关系树（up）",
	-- 		},
	-- 		{ "<space>csg", ":Cs f g <C-R><C-W><CR>", mode = "n", desc = "查找全局定义" },
	-- 		{ "csc", ":Cs f c <C-R><C-W><CR>", mode = "n", desc = "查找调用该函数的位置" },
	-- 		{ "cso", ":Cs f d <C-R><C-W><CR>", mode = "n", desc = "我调用的函数" },
	-- 		{ "cst", ":Cs f t <C-R><C-W><CR>", mode = "n", desc = "查找被该函数调用的位置" },
	-- 		{ "csa", ":Cs f a <C-R><C-W><CR>", mode = "n", desc = "查找赋值位置" },
	-- 	},
	-- 	config = function(_, opts)
	-- 		require("cscope_maps").setup(opts)
	-- 	end,
	-- },

	-- {
	-- 	"lolpie244/hover-notes.nvim",
	-- 	require("hover-notes").setup({
	-- 		notesDir = vim.fn.stdpath("data") .. "/hover-notes", -- the root directory where all notes are stored
	-- 		defaultCategory = { -- the default note category
	-- 			name = "Default",
	-- 			format = "{text}",
	-- 		},
	-- 		ui = { -- style of the float window
	-- 			float = {
	-- 				style = "minimal",
	-- 				border = "rounded",
	-- 			},
	-- 		},
	-- 		highlight = {
	-- 			enable = true,
	-- 			-- if length of words in dictionary is longer than subsstr_match_size_limit - use exact word match instead of substring
	-- 			subsstr_match_size_limit = 1000,
	-- 			style = {
	-- 				underline = true,
	-- 				sp = vim.api.nvim_get_hl(0, { name = "String", link = false }).fg,
	-- 				bold = true,
	-- 				default = true,
	-- 			},
	-- 		},
	-- 	}),
	-- },
}
