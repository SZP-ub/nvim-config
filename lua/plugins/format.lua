---@diagnostic disable: undefined-global
return {

	-- mason-tool-installer.nvim：自动安装常用格式化工具
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"clang-format", -- C/C++
					"stylua", -- Lua
					"prettier", -- JSON/Markdown/YAML/HTML/CSS/JS/TS/Markdown
					-- 你可以继续添加其他格式化工具
				},
				auto_update = false,
				run_on_start = true,
			})
		end,
	},

	-- conform.nvim：格式化配置
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					c = { "clang_format" },
					cpp = { "clang_format" },
					lua = { "stylua" },
					json = { "prettier" },
					markdown = { "prettier" },
					yaml = { "prettier" },
					html = { "prettier" },
					css = { "prettier" },
					javascript = { "prettier" },
					typescript = { "prettier" },
					-- gitconfig 通常不需要格式化器，如有需要可自定义
				},
				format_on_save = {
					lsp_fallback = true,
					timeout_ms = 300,
				},
			})
		end,
	},

	{
		-- 加载 nvim-lint 插件，用于代码静态检查（lint）
		"mfussenegger/nvim-lint",
		dependencies = {
			{
				"williamboman/mason.nvim", -- 依赖 mason.nvim，用于自动安装外部工具
				optional = true,
				opts = {
					ensure_installed = {
						"codespell", -- 确保 codespell 拼写检查工具已安装
					},
				},
				opts_extend = { "ensure_installed" },
			},
		},
		event = "BufWritePost", -- 在文件保存后触发
		config = function()
			-- 创建自动命令，在每次保存文件后执行
			vim.api.nvim_create_autocmd({ "BufWritePost" }, {
				callback = function()
					-- 自动根据 linters_by_ft 配置，对当前文件类型运行对应的 linter
					require("lint").try_lint()

					-- 强制运行 codespell linter（无论文件类型），用于拼写检查
					require("lint").try_lint("codespell")
				end,
			})
		end,
	},

	{
		"folke/trouble.nvim", -- 插件名：用于诊断、LSP、quickfix等信息的可视化展示
		cmd = "Trouble", -- 只在执行 Trouble 命令时加载插件（懒加载）
		keys = { -- 快捷键配置
			{
				"<A-j>",
				function()
					vim.diagnostic.jump({ count = 1 })
				end,
				mode = { "n" },
				desc = "跳转到下一个诊断",
			},
			{
				"<A-k>",
				function()
					vim.diagnostic.jump({ count = -1 })
				end,
				mode = { "n" },
				desc = "跳转到上一个诊断",
			},
			{
				"<leader>gd",
				"<CMD>Trouble diagnostics toggle<CR>",
				desc = "[Trouble] 切换当前 buffer 的诊断面板",
			},
			{ "<leader>gs", "<CMD>Trouble symbols toggle focus=false<CR>", desc = "[Trouble] 切换符号面板" },
			{
				"<leader>gl",
				"<CMD>Trouble lsp toggle focus=false win.position=right<CR>",
				desc = "[Trouble] 切换 LSP 定义/引用等",
			},
			{ "<leader>gL", "<CMD>Trouble loclist toggle<CR>", desc = "[Trouble] 位置列表" },
			{ "<leader>gq", "<CMD>Trouble qflist toggle<CR>", desc = "[Trouble] Quickfix 列表" },
			-- 以下为可选的 LSP 相关 Trouble 面板快捷键（已注释）
			-- { "grr", "<CMD>Trouble lsp_references focus=true<CR>", ... },
			-- { "gD", "<CMD>Trouble lsp_declarations focus=true<CR>", ... },
			-- { "gd", "<CMD>Trouble lsp_type_definitions focus=true<CR>", ... },
			-- { "gri", "<CMD>Trouble lsp_implementations focus=true<CR>", ... },
		},

		opts = { -- Trouble 插件的主配置
			focus = false,
			warn_no_results = false,
			open_no_results = true,
			preview = { -- 预览窗口样式
				type = "float",
				relative = "editor",
				border = "rounded",
				title = "Preview",
				title_pos = "center",
				position = { 0.3, 0.3 },
				size = { width = 0.6, height = 0.5 },
				zindex = 200,
			},
		},

		config = function(_, opts)
			require("trouble").setup(opts) -- 初始化 trouble.nvim
			-- 配置 trouble 的状态栏符号显示
			local symbols = require("trouble").statusline({
				mode = "lsp_document_symbols",
				groups = {},
				title = false,
				filter = { range = true },
				format = "{kind_icon}{symbol.name:Normal}",
				-- hl_group = "lualine_b_normal", -- 可选：修正状态栏背景色
			})

			-- 将 trouble 的符号状态插入到 lualine 的 winbar
			opts = require("lualine").get_config()
			table.insert(opts.winbar.lualine_b, 1, {
				symbols.get,
				cond = symbols.has,
			})
			require("lualine").setup(opts)
		end,
	},
}
