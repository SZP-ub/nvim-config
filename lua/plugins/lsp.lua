---@diagnostic disable: undefined-global
return {
	-- mason.nvim：基础设置和 UI
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate",
		opts = {
			ensure_installed = { "clangd", "marksman" },
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
			local mr = require("mason-registry") -- 加载 mason 的注册表模块

			-- 定义一个确保工具已安装的函数
			local function ensure_installed()
				for _, tool in ipairs(opts.ensure_installed) do -- 遍历 ensure_installed 列表
					local p = mr.get_package(tool) -- 获取工具包对象
					if not p:is_installed() then -- 如果未安装
						p:install() -- 执行安装
					end
				end
			end

			-- 如果 mason-registry 支持 refresh，则刷新后再确保安装
			if mr.refresh then
				mr.refresh(ensure_installed)
			else
				ensure_installed()
			end
		end,
	},

	-- nvim-lspconfig：LSP 配置（可选，与你原有配置合并）
	{
		"neovim/nvim-lspconfig",
		dependencies = { "williamboman/mason.nvim", "saghen/blink.cmp" },
		config = function()
			vim.diagnostic.config({
				underline = false,
				signs = false,
				update_in_insert = false,
				virtual_text = { spacing = 2, prefix = "●" },
				severity_sort = true,
				float = {
					border = "rounded",
				},
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, {
						buffer = ev.buf,
						desc = "[LSP] Show diagnostic",
					})
					vim.keymap.set("n", "<leader>gk", vim.lsp.buf.signature_help, { desc = "[LSP] Signature help" })
					vim.keymap.set(
						"n",
						"<leader>wa",
						vim.lsp.buf.add_workspace_folder,
						{ desc = "[LSP] Add workspace folder" }
					)
					vim.keymap.set(
						"n",
						"<leader>wr",
						vim.lsp.buf.remove_workspace_folder,
						{ desc = "[LSP] Remove workspace folder" }
					)
					vim.keymap.set("n", "<leader>wl", function()
						print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
					end, { desc = "[LSP] List workspace folders" })
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = ev.buf, desc = "[LSP] Rename" })
				end,
			})
		end,
	},
}
