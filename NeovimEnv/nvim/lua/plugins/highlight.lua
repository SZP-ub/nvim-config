---@diagnostic disable: undefined-global
return {

	---------------------------------------------------------------------------
	-- 1. nvim-treesitter 核心配置
	---------------------------------------------------------------------------
	{
		"nvim-treesitter/nvim-treesitter",
		event = "VeryLazy",
		branch = "master",
		build = ":TSUpdate",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		config = function()
			require("nvim-treesitter.install").compilers = { "cl" }

			require("nvim-treesitter.configs").setup({
				auto_install = false,
				sync_install = false,
				ensure_installed = {
					"lua",
					"vim",
					"markdown",
					"markdown_inline",
					"regex", -- ★ 新增：Noice 搜索与正则高亮必须依赖
					"bash", -- ★ 新增：Noice 终端命令过滤高亮依赖
					-- 非目标语言解析器保持注释：
					-- "diff",
					-- "cmake",
					-- "bash",
					-- "c",
					-- "cpp",
					-- "vimdoc",
					-- "query",
					-- "javascript",
					-- "html",
					-- "json",
					-- "python",
					-- "typescript",
					-- "java",
				},
				ignore_install = {},

				highlight = {
					enable = true,
					-- 显式禁用 treesitter 对 latex 的接管，由 VimTeX 原生接管最佳
					disable = { "latex" },
					additional_vim_regex_highlighting = false,
				},

				indent = {
					enable = true,
				},

				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "gnn",
						node_incremental = "grn",
						scope_incremental = "grc",
						node_decremental = "grm",
					},
				},

				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
							["ap"] = "@parameter.outer",
							["ip"] = "@parameter.inner",
						},
						selection_modes = {
							["@parameter.outer"] = "v",
							["@function.outer"] = "v",
						},
						include_surrounding_whitespace = false,
					},
					move = {
						enable = true,
						set_jumps = true,
						goto_next_start = { ["]f"] = "@function.outer" },
						goto_next_end = { ["]F"] = "@function.outer" },
						goto_previous_start = { ["[f"] = "@function.outer" },
						goto_previous_end = { ["[F"] = "@function.outer" },
					},
					swap = {
						enable = true,
						swap_next = { ["gsp"] = "@parameter.inner" },
						swap_previous = { ["gsP"] = "@parameter.inner" },
					},
					lsp_interop = {
						enable = true,
						peek_definition_code = {
							["gpf"] = "@function.outer",
							["gpc"] = "@class.outer",
						},
					},
				},
			})
		end,
	},

	---------------------------------------------------------------------------
	-- 2. nvim-treesitter-textobjects 按键声明
	---------------------------------------------------------------------------
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		lazy = true,
		keys = {
			{ "af", mode = { "o", "x" } },
			{ "if", mode = { "o", "x" } },
			{ "ac", mode = { "o", "x" } },
			{ "ic", mode = { "o", "x" } },
			{ "ap", mode = { "o", "x" } },
			{ "ip", mode = { "o", "x" } },
			{ "]f", mode = "n" },
			{ "[f", mode = "n" },
			{ "]F", mode = "n" },
			{ "[F", mode = "n" },
			{ "gsp", mode = "n" },
			{ "gsP", mode = "n" },
			{ "gpf", mode = "n" },
			{ "gpc", mode = "n" },
		},
	},

	---------------------------------------------------------------------------
	-- 3. rainbow-delimiters.nvim：彩虹括号（支持 LaTeX 块）
	---------------------------------------------------------------------------
	{
		"HiPhish/rainbow-delimiters.nvim",
		config = function()
			local rainbow_delimiters = require("rainbow-delimiters")
			vim.g.rainbow_delimiters = {
				strategy = {
					[""] = rainbow_delimiters.strategy["global"],
				},
				query = {
					[""] = "rainbow-delimiters",
					latex = "rainbow-blocks",
				},
			}
		end,
	},

	---------------------------------------------------------------------------
	-- 4. wildfire.nvim：快速结构化选择
	---------------------------------------------------------------------------
	{
		"sustech-data/wildfire.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		keys = {
			{ "<CR>", mode = { "n", "x" }, desc = "wildfire 区块选择/扩展" },
			{ "<BS>", mode = { "n", "x" }, desc = "wildfire 区块收缩" },
		},
		config = function()
			require("wildfire").setup({
				surrounds = {
					{ "(", ")" },
					{ "{", "}" },
					{ "<", ">" },
					{ "[", "]" },
					{ "`", "`" },
					{ '"', '"' },
					{ "'", "'" },
				},
				keymaps = {
					init_selection = "<CR>",
					node_incremental = "<CR>",
					node_decremental = "<BS>",
				},
				filetype_exclude = { "qf" },
			})
		end,
	},
}

