---@diagnostic disable: undefined-global
-- ============================================================================
-- 插件：folke/noice.nvim
-- 架构：Noice 接管命令行/消息/LSP浮窗，cmp-cmdline 驱动命令行实时补全
-- ============================================================================

return {
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			{
				"rcarriga/nvim-notify",
				opts = {
					background_colour = "#fbf1c7", -- 匹配 gruvbox-material light medium 背景，消除警告
					timeout = 3000,
					stages = "fade",
					render = "compact",
					max_width = 50,
					max_height = 10,
					top_down = true, -- 右上角向下自然展开
				},
			},
		},
		opts = {
			-- 1. LSP 交互、文档渲染与进度指示（单一配置块，避免覆盖）
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true, -- 依赖 hrsh7th/nvim-cmp
				},
				hover = {
					enabled = true,
					silent = true, -- 无悬停文档时不弹出 "No information available" 打扰
					opts = {
						border = { style = "rounded", padding = { 0, 1 } },
						position = { row = 2, col = 0 },
					},
				},
				signature = {
					enabled = true,
					auto_open = {
						enabled = true,
						trigger = true,
						luasnip = true,
						throttle = 50,
					},
					opts = { border = { style = "rounded" } },
				},
				progress = {
					enabled = true,
					format = "lsp_progress",
					format_done = "lsp_progress_done",
					throttle = 1000 / 30,
					view = "mini",
				},
				message = {
					enabled = true,
					view = "notify",
					opts = {},
				},
			},

			-- 2. 命令行（Cmdline）管理
			cmdline = {
				enabled = true,
				backend = "cmp",
				view = "cmdline_popup",
				opts = {
					border = { style = "rounded" },
					win_options = {
						winhighlight = { Normal = "NormalFloat", FloatBorder = "FloatBorder" },
					},
				},
				format = {
					cmdline = { pattern = "^:", icon = "", lang = "vim", title = " 󰘳 Command " },
					search_down = {
						kind = "search",
						pattern = "^/",
						icon = " ",
						lang = "regex",
						title = " Search ",
					},
					search_up = {
						kind = "search",
						pattern = "^%?",
						icon = " ",
						lang = "regex",
						title = " Search Up ",
					},
					filter = { pattern = "^:%s*!", icon = "", lang = "bash", title = " Shell " },
					lua = {
						pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" },
						icon = "",
						lang = "lua",
						title = " Lua ",
					},
					help = { pattern = "^:%s*he?l?p?%s+", icon = "", title = " Help " },
					input = { view = "cmdline_input", icon = "󰥻 " },
				},
			},

			-- 3. 消息与通知视图
			messages = {
				enabled = true,
				view = "notify",
				view_error = "notify",
				view_warn = "notify",
				view_history = "messages",
				view_search = "virtualtext",
			},

			notify = {
				enabled = true,
				view = "notify",
			},

			-- 4. 原生补全菜单回退（日常 : 与 / 补全由 lsp.lua 中的 cmp-cmdline 驱动）
			popupmenu = {
				enabled = true,
				backend = "cmp",
			},

			-- 5. 消息路由规则
			routes = {
				{
					filter = { event = "notify", find = "You're using a GUI that uses ext_" },
					opts = { skip = true },
				},
				{ view = "split", filter = { event = "msg_show", min_height = 20 } },
				{ filter = { event = "msg_show", kind = "", find = "written" }, opts = { skip = true } },
				{ filter = { event = "msg_show", find = "vimtex" }, view = "mini" },
				{ filter = { event = "msg_show", find = "E486: Pattern not found" }, opts = { skip = true } },
			},

			-- 6. 官方推荐预设
			presets = {
				bottom_search = false,
				command_palette = true, -- 命令行与弹窗菜单顶部居中一体化
				long_message_to_split = true,
				inc_rename = false,
				lsp_doc_border = true,
			},

			-- 7. 自定义视图定位
			views = {
				cmdline_popup = {
					position = { row = 5, col = "50%" },
					size = { width = 60, height = "auto" },
				},
				popupmenu = {
					relative = "editor",
					position = { row = 8, col = "50%" },
					size = { width = 60, height = 10 },
					border = { style = "rounded", padding = { 0, 1 } },
					win_options = {
						winhighlight = { Normal = "NormalFloat", FloatBorder = "FloatBorder" },
					},
				},
				mini = {
					position = { row = 1, col = "100%" },
					win_options = { winblend = 0 },
				},
			},
		},

		-- 8. 快捷键（配合 format.lua 中的 trouble.nvim 使用）
		keys = {
			{
				"<leader>snl",
				function()
					require("noice").cmd("last")
				end,
				desc = "[Noice] 查看最后一条消息",
			},
			{
				"<leader>snh",
				function()
					require("noice").cmd("history")
				end,
				desc = "[Noice] 浏览消息历史",
			},
			{
				"<leader>snd",
				function()
					require("noice").cmd("dismiss")
				end,
				desc = "[Noice] 关闭所有通知",
			},
			{ "<leader>sx", "<cmd>Noice trouble<cr>", desc = "[Noice] 在 Trouble 中查看全量日志" },
			{
				"<c-f>",
				function()
					if not require("noice.lsp").scroll(4) then
						return "<c-f>"
					end
				end,
				silent = true,
				expr = true,
				desc = "[Noice] 悬浮窗向下滚动",
				mode = { "i", "n", "s" },
			},
			{
				"<c-b>",
				function()
					if not require("noice.lsp").scroll(-4) then
						return "<c-b>"
					end
				end,
				silent = true,
				expr = true,
				desc = "[Noice] 悬浮窗向上滚动",
				mode = { "i", "n", "s" },
			},
		},
	},
}
