---@diagnostic disable: undefined-global
return {

	{
		"chentoast/marks.nvim",
		-- 去掉 event 自动加载，仅在按下以下按键时瞬间唤醒插件
		keys = {
			{ "m", mode = "n", desc = "设置标记" },
			{ "dm", mode = "n", desc = "删除标记" },
			{ "]`", mode = "n", desc = "下一个标记" },
			{ "[`", mode = "n", desc = "上一个标记" },
			{ "'", mode = "n", desc = "跳转到标记行" },
			{ "`", mode = "n", desc = "跳转到标记位置" },
		},
		opts = {
			mappings = {
				next = "]`",
				prev = "[`",
				delete = "dm",
				delete_line = "dm-",
				delete_buf = "dm<space>",
			},
		},

		vim.keymap.set("n", "<leader>fm", "<cmd>Telescope marks<cr>", { desc = "查找书签" }),
	},

	-- 书签标记可视化插件（轻量显示 a-z 标记）
	-- {
	-- 	"kshenoy/vim-signature",
	-- 	event = "VeryLazy",
	-- 	keys = {
	-- 		{ "m", mode = "n", desc = "添加/跳转标记" },
	-- 		{ "dm", mode = "n", desc = "删除标记" },
	-- 		{ "'", mode = "n", desc = "跳转到标记" },
	-- 		{ "`", mode = "n", desc = "跳转到标记" },
	-- 		{ "]`", mode = "n", desc = "下一个标记" },
	-- 		{ "[`", mode = "n", desc = "上一个标记" },
	-- 	},
	-- },

	-- 文件树侧边栏
	{
		"nvim-tree/nvim-tree.lua",
		keys = {
			{ "<C-n>", "<cmd>NvimTreeToggle<CR>", desc = "切换 NvimTree" },
		},
		config = function()
			require("nvim-tree").setup({
				sort_by = "case_sensitive",
				view = { width = 20 },
				renderer = { group_empty = true },
				filters = { dotfiles = true },
				actions = {
					open_file = {
						-- 修正：原游离变量修复，防止在终端窗口内直接替换打开文件
						window_picker = {
							enable = true,
							exclude = {
								buftype = { "terminal", "quickfix" },
							},
						},
					},
				},
			})
		end,
	},

	-- [非目标功能：已注释保留]
	-- 代码结构标签栏（依赖 ctags，主要面向 C/C++；LaTeX 专属大纲使用 VimTeX TOC，Markdown 使用 Trouble）
	-- {
	-- 	"preservim/tagbar",
	-- 	keys = {
	-- 		{
	-- 			"<leader>o",
	-- 			"<cmd>TagbarToggle<CR>",
	-- 			desc = "切换 Tagbar 代码结构窗口",
	-- 		},
	-- 	},
	-- 	config = function()
	-- 		vim.g.tagbar_autofocus = 1
	-- 		vim.g.tagbar_width = 20
	-- 		vim.g.tagbar_sort = 0
	-- 	end,
	-- },
	-- {
	-- 	"stevearc/aerial.nvim",
	-- 	opts = {
	-- 		-- 优先使用 treesitter 解析 markdown 标题
	-- 		backends = { "treesitter", "lsp", "markdown", "man" },
	-- 		layout = {
	-- 			default_direction = "prefer_right",
	-- 			width = 32,
	-- 		},
	-- 		-- 允许在侧边栏内过滤
	-- 		filter_kind = false,
	-- 	},
	-- 	keys = {
	-- 		{ "<leader>to", "<cmd>AerialToggle!<CR>", desc = "Toggle Outline" },
	-- 		{ "<leader>so", "<cmd>AerialNavToggle<CR>", desc = "Search Outline Nav" },
	-- 	},
	-- },
	-- nvim-ufo 折叠增强（保持原有注释）
	-- {
	-- 	"kevinhwang91/nvim-ufo",
	-- ...
	-- },
}
