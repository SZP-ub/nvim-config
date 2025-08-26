return {

	-- mason.nvim：用于管理 LSP/DAP/Linter/Formatter 的安装
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		opts = {
			ensure_installed = {}, -- 需要自动安装的工具列表
			ui = {
				border = "rounded",
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
		opts_extend = { "ensure_installed" },
		config = function(_, opts)
			require("mason").setup(opts)
			local mr = require("mason-registry")

			-- 确保 ensure_installed 中的工具都已安装
			local function ensure_installed()
				for _, tool in ipairs(opts.ensure_installed) do
					local p = mr.get_package(tool)
					if not p:is_installed() then
						p:install()
					end
				end
			end
			-- mason-registry 支持 refresh 时，先刷新再安装
			if mr.refresh then
				mr.refresh(ensure_installed)
			else
				ensure_installed()
			end
		end,
	},

	{
		"saghen/blink.cmp",
		-- 可选依赖：为 snippet 补全源提供丰富的代码片段
		-- dependencies = { "rafamadriz/friendly-snippets" },

		-- 推荐使用 release tag，下载预编译二进制文件
		version = "1.*",
		-- 或者从源码构建（需要 Rust nightly 版本），可选
		-- build = 'cargo build --release',
		-- 如果你用 nix，也可以用 nightly rust 构建
		-- build = 'nix run .#build-plugin',

		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			-- 补全菜单的快捷键预设
			-- 'default'：类似内置补全（C-y 接受补全，推荐）
			-- 'super-tab'：类似 vscode（Tab 接受补全）
			-- 'enter'：回车接受补全
			-- 'none'：不设置快捷键
			-- 所有预设都支持：
			--   C-space：打开菜单或文档
			--   C-n/C-p 或 上下键：选择补全项
			--   C-e：关闭菜单
			--   C-k：切换签名帮助（如果 signature.enabled = true）
			-- 详见 :h blink-cmp-config-keymap
			keymap = {
				-- 这里自定义 Tab 和 Enter 都接受补全
				accept = { "<Tab>", "<CR>" },
				-- 其它按键可按需自定义
				next = { "<Tab>", "<down>" },
				prev = { "<S-Tab>", "<up>" },
				menu = { "<C-Space>" },
				close = { "<C-e>" },
				docs = { "<C-d>" },
				signature = { "<C-k>" },
			},
			appearance = {
				-- 'mono'（默认）：适用于 Nerd Font Mono
				-- 'normal'：适用于 Nerd Font
				-- 用于调整图标对齐
				nerd_font_variant = "mono",
			},

			-- 默认：仅手动触发时显示文档弹窗
			completion = { documentation = { auto_show = false } },

			-- 默认启用的补全源，可在其它配置中扩展
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},

			-- 默认使用 Rust 实现的模糊匹配，性能更好且容错性强
			-- 也可用 lua 实现（implementation = "lua"），或优先用 Rust 不可用时用 lua（"prefer_rust"）
			-- 详见 fuzzy 文档
			fuzzy = { implementation = "prefer_rust_with_warning" },
		},
		-- 支持扩展 sources.default
		opts_extend = { "sources.default" },
	},

	-- mason-lspconfig：自动桥接 mason 和 lspconfig
	{
		"williamboman/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {},
			automatic_installation = true,
		},
		config = function(_, opts)
			require("mason-lspconfig").setup(opts)
		end,
	},

	-- nvim-lspconfig：LSP 客户端配置
	{
		"neovim/nvim-lspconfig",
		dependencies = { "saghen/blink.cmp", "williamboman/mason.nvim" },

		opts = {
			servers = {
				lua_ls = {},
			},
		},

		config = function()
			local capabilities = require("blink.cmp").get_lsp_capabilities()
			local lspconfig = require("lspconfig")
			lspconfig["lua_ls"].setup({ capabilities = capabilities })

			vim.diagnostic.config({
				underline = false,
				signs = false,
				update_in_insert = false,
				virtual_text = { spacing = 2, prefix = "●" },
				severity_sort = true,
				float = { border = "rounded" },
			})

			-- 定义 show_doc 函数，K 键显示文档
			local function show_doc()
				local filetype = vim.bo.filetype
				if vim.lsp.buf.server_ready() then
					vim.lsp.buf.hover()
				else
					vim.api.nvim_feedkeys("K", "in", false)
				end
			end

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					local opts = { buffer = ev.buf, silent = true }

					-- 跳转诊断
					vim.keymap.set("n", "[g", vim.diagnostic.goto_prev, opts)
					vim.keymap.set("n", "]g", vim.diagnostic.goto_next, opts)

					-- 跳转到定义/类型定义/实现/引用
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
					vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

					-- K 显示文档
					vim.keymap.set("n", "K", show_doc, opts)

					-- 重命名
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

					-- 代码操作
					vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action, opts)
					vim.keymap.set("x", "<leader>a", vim.lsp.buf.code_action, opts)
					vim.keymap.set("n", "<leader>ac", vim.lsp.buf.code_action, opts)
					vim.keymap.set("n", "<leader>as", function()
						vim.lsp.buf.code_action({ context = { only = { "source" } } })
					end, opts)

					-- 快速修复
					vim.keymap.set("n", "<leader>qf", function()
						vim.lsp.buf.code_action({ context = { only = { "quickfix" } } })
					end, opts)

					-- 重构
					vim.keymap.set("n", "<leader>re", function()
						vim.lsp.buf.code_action({ context = { only = { "refactor" } } })
					end, opts)
					vim.keymap.set("x", "<leader>r", function()
						vim.lsp.buf.range_code_action({ context = { only = { "refactor" } } })
					end, opts)
					vim.keymap.set("n", "<leader>r", function()
						vim.lsp.buf.code_action({ context = { only = { "refactor" } } })
					end, opts)

					-- CodeLens
					vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, opts)

					-- 保存时自动格式化
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = ev.buf,
						callback = function()
							vim.lsp.buf.format({ async = false })
						end,
					})

					vim.keymap.set("n", "gc", function()
						vim.lsp.buf_request(0, "$ccls/call", { callee = false }, function(_, result)
							print(vim.inspect(result))
						end)
					end, { desc = "查找调用者（ccls）" })
					vim.keymap.set("n", "gcc", function()
						vim.lsp.buf_request(0, "$ccls/call", { callee = true }, function(_, result)
							print(vim.inspect(result))
						end)
					end, { desc = "查找被调用（ccls）" })
				end,
			})
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("nvim-treesitter.configs").setup({
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							-- 内部函数/类
							["if"] = "@function.inner",
							["ic"] = "@class.inner",
							-- 外部函数/类
							["af"] = "@function.outer",
							["ac"] = "@class.outer",
						},
					},
				},
			})
			-- <C-s> 选择范围（treesitter 提供增量选择，推荐用 <C-space> 和 <BS>）
			vim.keymap.set(
				"n",
				"<C-s>",
				"<cmd>lua require('nvim-treesitter.incremental_selection').init_selection()<CR>",
				{ desc = "开始增量选择" }
			)
			vim.keymap.set(
				"x",
				"<C-s>",
				"<cmd>lua require('nvim-treesitter.incremental_selection').node_incremental()<CR>",
				{ desc = "增量选择" }
			)
			vim.keymap.set(
				"x",
				"<BS>",
				"<cmd>lua require('nvim-treesitter.incremental_selection').node_decremental()<CR>",
				{ desc = "减少选择" }
			)
		end,
	},
}
