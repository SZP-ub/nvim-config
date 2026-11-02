---@diagnostic disable: undefined-global
return {
	-- =========================
	-- mason-tool-installer：格式化 / lint 工具自动安装
	-- =========================
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason-org/mason.nvim",
		},
		config = function()
			local ok, mti = pcall(require, "mason-tool-installer")
			if not ok then
				return
			end
			mti.setup({
				ensure_installed = {
					"stylua", -- 针对 Lua 配置的格式化工具
					"prettier", -- Markdown 格式化
					"codespell", -- 拼写检查
					"tex-fmt", -- LaTeX 格式化工具
					"clang-format", -- C/C++ (已注释)
					"ruff", -- .py格式化工具
				},
				auto_update = true,
				run_on_start = true,
			})
		end,
	},

	-- =========================
	-- conform.nvim：手动触发“先格式化再保存”
	-- =========================

	{
		"stevearc/conform.nvim",
		keys = {
			{
				"<space>w",
				function()
					local conform = require("conform")
					-- 必须设为 async = false，等待格式化完成后再写入磁盘
					conform.format({
						lsp_fallback = true,
						timeout_ms = 2000,
						async = false,
					})
					vim.cmd("update")
				end,
				mode = "n",
				desc = "Format buffer and write",
			},
		},

		config = function()
			local ok, conform = pcall(require, "conform")
			if not ok then
				return
			end

			conform.setup({
				formatters_by_ft = {
					lua = { "stylua" },
					markdown = { "prettier" },
					["markdown.mdx"] = { "prettier" },
					tex = { "tex-fmt" },
					c = { "clang_format" },
					cpp = { "clang_format" },
					yaml = { "prettier" },
					html = { "prettier" },
					py = { "ruff" },
				},
				formatters = {
					prettier = {
						prepend_args = { "--tab-width", "4" },
					},
				},
			})
		end,
	},

	-- {
	-- 	"stevearc/conform.nvim",
	-- 	keys = {
	-- 		{
	-- 			"<space>w",
	-- 			function()
	-- 				local conform = require("conform")
	-- 				conform.format({
	-- 					lsp_fallback = true,
	-- 					timeout_ms = 2000,
	-- 				})
	-- 				vim.cmd("write")
	-- 			end,
	-- 			mode = "n",
	-- 			desc = "Format buffer and write",
	-- 		},
	-- 	},
	--
	-- 	config = function()
	-- 		local ok, conform = pcall(require, "conform")
	-- 		if not ok then
	-- 			return
	-- 		end
	--
	-- 		conform.setup({
	-- 			formatters_by_ft = {
	-- 				lua = { "stylua" }, -- 激活 Lua 格式化
	-- 				markdown = { "prettier" },
	-- 				["markdown.mdx"] = { "prettier" },
	-- 				tex = { "tex-fmt" },
	-- 				-- 非目标语言格式化规则保持注释：
	-- 				c = { "clang_format" },
	-- 				cpp = { "clang_format" },
	-- 				-- json = { "prettier" },
	-- 				-- jsonc = { "prettier" },
	-- 				yaml = { "prettier" },
	-- 				html = { "prettier" },
	-- 				-- css = { "prettier" },
	-- 				-- javascript = { "prettier" },
	-- 				-- typescript = { "prettier" },
	-- 				-- javascriptreact = { "prettier" },
	-- 				-- typescriptreact = { "prettier" },
	-- 				-- make = { "mbake" },
	-- 				-- mk = { "mbake" },
	-- 				-- makefile = { "mbake" },
	-- 			},
	-- 			formatters = {
	-- 				prettier = {
	-- 					prepend_args = { "--tab-width", "4" },
	-- 				},
	-- 				-- mbake = {
	-- 				-- 	command = vim.fn.stdpath("data") .. "/mason/bin/mbake",
	-- 				-- 	args = { "format", "--stdin" },
	-- 				-- 	stdin = true,
	-- 				-- },
	-- 			},
	-- 		})
	-- 	end,
	-- },

	-- =========================
	-- nvim-lint：保存后自动 lint
	-- =========================
	{
		"mfussenegger/nvim-lint",
		event = "VeryLazy",
		config = function()
			local ok, lint = pcall(require, "lint")
			if not ok then
				return
			end

			lint.linters_by_ft = {
				markdown = { "codespell" },
				tex = { "codespell" },
				lua = { "codespell" },
				c = { "codespell" },
				cpp = { "codespell" },
				py = { "codespell" },
			}

			vim.api.nvim_create_autocmd("BufWritePost", {
				group = vim.api.nvim_create_augroup("nvim-lint-auto", { clear = true }),
				callback = function(args)
					if vim.bo[args.buf].buftype ~= "" then
						return
					end
					lint.try_lint()
				end,
			})
		end,
	},

	-- =========================
	-- Trouble：诊断 / LSP 列表可视化
	-- =========================
	{
		"folke/trouble.nvim",
		-- event = "VeryLazy",
		lazy = true,
		cmd = { "Trouble" },
		keys = {
			-- 对齐 Tagbar 体验：打开右侧大纲树并立即聚焦
			{
				"<leader>gs",
				"<cmd>Trouble symbols toggle<cr>",
				desc = "[Trouble] 切换代码大纲 (Tagbar 风格)",
			},
			-- LSP 引用/定义列表(谁调用了我)
			{
				"<leader>cl",
				"<cmd>Trouble lsp toggle<cr>",
				desc = "[Trouble] LSP 引用与定义列表",
			},
			-- 其余诊断列表保持原有映射
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "[Trouble] 项目全量诊断" },
			{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "[Trouble] 当前文件诊断" },
			{ "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "[Trouble] Quickfix 列表" },
			{ "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "[Trouble] Location 列表" },
		},
		opts = {
			focus = true, -- 打开时自动将光标移入大纲内 (对齐 tagbar_autofocus = 1)
			warn_no_results = false,
			open_no_results = true,
			auto_refresh = true, -- 保存时自动更新大纲
			auto_close = false, -- 点击跳转后不关闭侧边栏
			follow = true, -- 主窗口移动光标时，大纲自动跟随高亮
			indent_guides = true, -- 显示类似 Tagbar 的分支引导虚线
			max_items = 500, -- 容纳更长的大纲列表
			multiline = false, -- 大纲模式下保持单行整齐排列，不折行

			-- 全局基础窗口配置（主要服务于底部诊断）
			win = {
				type = "split",
				position = "bottom",
				size = 30,
			},

			-- 窗口内快捷键（完全贴合 Tagbar 肌肉记忆）
			keys = {
				["?"] = "help",
				["r"] = "refresh",
				["q"] = "close", -- q 键退出
				["<esc>"] = "cancel",
				["<cr>"] = "jump", -- 回车跳转
				-- ["o"] = "jump", -- o 键跳转并保持在代码处
				["p"] = "toggle_preview", -- 需要时按 p 手动开关内联预览
				["o"] = "fold_toggle", -- x 键切换当前节点折叠
				["za"] = "fold_toggle", -- 对齐 Vim 原生折叠按键
				["zR"] = "fold_open_all", -- 展开所有折叠 (Tagbar 习惯)
				["zM"] = "fold_close_all", -- 折叠所有节点 (Tagbar 习惯)

				-- 窗口宽度微调
				["+"] = {
					action = function()
						vim.cmd("vertical resize +5")
					end,
					desc = "加宽 5 列",
				},
				["-"] = {
					action = function()
						vim.cmd("vertical resize -5")
					end,
					desc = "减窄 5 列",
				},
			},

			icons = {
				indent = {
					top = "│ ",
					middle = "├─",
					last = "└─",
					fold_open = "▾ ", -- 展开标记
					fold_closed = "▸ ", -- 折叠标记
					ws = "  ",
				},
				folder_closed = "▸ ",
				folder_open = "▾ ",

				-- folder_closed = " ",
				-- folder_open = " ",
				kinds = {
					Array = " ",
					Boolean = "󰨙 ",
					Class = " ",
					Constant = "󰏿 ",
					Constructor = " ",
					Enum = " ",
					EnumMember = " ",
					Event = " ",
					Field = "󰜢 ",
					File = "󰈙 ",
					Function = "󰊕 ",
					Interface = " ",
					Key = " ",
					Method = "󰆧 ",
					Module = " ",
					Namespace = "󰦮 ",
					Null = " ",
					Number = "󰎠 ",
					Object = " ",
					Operator = " ",
					Package = " ",
					Property = " ",
					String = " ",
					Struct = "󰙅 ",
					TypeParameter = " ",
					Variable = "󰀫 ",
				},
			},

			-- =================================================================
			-- 核心：Tagbar 风格大纲定制
			-- =================================================================
			modes = {
				symbols = {
					desc = "当前文档结构大纲 (Tagbar 模式)",
					mode = "lsp_document_symbols",
					focus = true, -- 自动聚焦
					pinned = true, -- ★ 锁定到当前编辑的代码窗口，避免切 buffer 时扰乱
					auto_preview = false, -- ★ 关闭浮动预览弹窗，保持如 Tagbar 般清爽的纯文本大纲

					-- 窗口布局配置
					win = {
						position = "right", -- 固定在屏幕右侧
						size = 25, -- 初始宽度设为 25 列 (紧凑 Tagbar 尺寸)
					},

					-- 过滤掉对大纲导航无实质意义的冗余节点
					filter = {
						["not"] = {
							ft = "lua",
							kind = "Package",
						},
					},
				},

				-- LSP 聚合视图（保持适度宽度）
				lsp = {
					desc = "LSP 定义与引用列表",
					mode = "lsp",
					focus = true,
					win = {
						position = "right",
						size = 0.3,
					},
				},
			},
		},
		config = function(_, opts)
			require("trouble").setup(opts or {})

			-- 保持你原有的 Lualine Winbar 面包屑联动
			local ok_statusline, symbols = pcall(require("trouble").statusline, {
				mode = "lsp_document_symbols",
				groups = {},
				title = false,
				filter = { range = true },
				format = "{kind_icon}{symbol.name:Normal}",
				hl_group = "lualine_b_normal",
			})

			if not ok_statusline or not symbols then
				return
			end

			local function winbar_symbols_fallback()
				if symbols.has and symbols.has() then
					return symbols.get()
				end
				return " "
			end

			local lualine_ok, lualine = pcall(require, "lualine")
			if not lualine_ok then
				return
			end

			local lualine_opts = lualine.get_config() or {}
			lualine_opts.winbar = lualine_opts.winbar or {}
			lualine_opts.winbar.lualine_b = lualine_opts.winbar.lualine_b or {}

			table.insert(lualine_opts.winbar.lualine_b, 1, {
				winbar_symbols_fallback,
				color = { gui = "none" },
				cond = function()
					return true
				end,
			})

			lualine.setup(lualine_opts)
		end,
	},

	-- {
	-- 	"folke/trouble.nvim",
	-- 	event = "VeryLazy",
	-- 	cmd = { "Trouble" },
	-- 	-- 核心推荐快捷键组合（可根据使用习惯增删）
	-- 	keys = {
	-- 		-- 1. 项目级全量诊断（编译报错、警告、代码提示）
	-- 		{
	-- 			"<leader>xx",
	-- 			"<cmd>Trouble diagnostics toggle<cr>",
	-- 			desc = "[Trouble] 项目全量诊断列表 (Project Diagnostics)",
	-- 		},
	-- 		-- 2. 当前缓冲区单文件诊断（仅关注当前编辑的代码/文档）
	-- 		{
	-- 			"<leader>xX",
	-- 			"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
	-- 			desc = "[Trouble] 当前文件诊断 (Buffer Diagnostics)",
	-- 		},
	-- 		-- 3. LSP 符号与大纲树（对应你原配置中的 <leader>gs）
	-- 		{
	-- 			"<leader>gs",
	-- 			"<cmd>Trouble symbols toggle focus=true<cr>",
	-- 			desc = "[Trouble] 文档符号/大纲树 (Document Symbols)",
	-- 		},
	-- 		-- 4. LSP 定义、引用、实现与类型聚合视图
	-- 		{
	-- 			"<leader>cl",
	-- 			"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
	-- 			desc = "[Trouble] LSP 定义/引用/实现列表 (LSP Definitions & References)",
	-- 		},
	-- 		-- 5. Quickfix 快速修复列表替代视图
	-- 		{
	-- 			"<leader>xQ",
	-- 			"<cmd>Trouble qflist toggle<cr>",
	-- 			desc = "[Trouble] Quickfix 列表 (Quickfix List)",
	-- 		},
	-- 		-- 6. Location 位置列表替代视图
	-- 		{
	-- 			"<leader>xL",
	-- 			"<cmd>Trouble loclist toggle<cr>",
	-- 			desc = "[Trouble] Location 列表 (Location List)",
	-- 		},
	-- 	},
	-- 	opts = {
	-- 		-------------------------------------------------------------------
	-- 		-- 1. 基础行为与生命周期配置
	-- 		-------------------------------------------------------------------
	-- 		-- 当用户在列表中按回车选中并跳转到目标代码后，是否自动关闭 Trouble 窗口
	-- 		auto_close = false,
	--
	-- 		-- 当产生新的错误/警告等条目时，是否自动弹窗打开 Trouble
	-- 		auto_open = false,
	--
	-- 		-- 光标在列表中上下移动时，主编辑区是否自动联动实时预览对应位置代码
	-- 		auto_preview = true,
	--
	-- 		-- 当文件被修改保存或诊断状态改变时，是否自动重新渲染刷新列表
	-- 		auto_refresh = true,
	--
	-- 		-- 若列表中仅有唯一一条结果，执行打开命令时是否自动直接跳转到该位置
	-- 		auto_jump = false,
	--
	-- 		-- 打开 Trouble 窗口时，是否自动将光标焦点移入该列表窗口中
	-- 		focus = false,
	--
	-- 		-- 关闭 Trouble 窗口时，是否自动恢复先前聚焦的编辑窗口
	-- 		restore = true,
	--
	-- 		-- 编辑主窗口移动光标时，Trouble 列表内是否自动追踪高亮对应的条目
	-- 		follow = true,
	--
	-- 		-- 在多级树状结构视图中，是否绘制竖向缩进引导虚线
	-- 		indent_guides = true,
	--
	-- 		-- 单个列表视图中允许渲染的最大条目上限，防止巨型工程卡死
	-- 		max_items = 200,
	--
	-- 		-- 是否允许超长报错信息在列表中进行换行完整显示（false 则单行截断）
	-- 		multiline = true,
	--
	-- 		-- 是否将当前打开的列表视图锁定（钉住），避免被后续其他模式自动覆盖
	-- 		pinned = false,
	--
	-- 		-- 当搜索/检索没有发现任何结果时，是否在右下角弹出黄色警告提示
	-- 		warn_no_results = false,
	--
	-- 		-- 当没有任何结果项时，是否仍然允许打开一个空内容的 Trouble 窗口
	-- 		open_no_results = true,
	--
	-- 		-------------------------------------------------------------------
	-- 		-- 2. 窗口布局与渲染行为 (主列表窗口)
	-- 		-------------------------------------------------------------------
	-- 		win = {
	-- 			-- 窗口呈现类型: "split" (分屏侧边栏/底栏) 或 "float" (浮动弹窗)
	-- 			type = "split",
	-- 			-- 分屏停靠方位: "bottom" (底栏) | "top" (顶栏) | "left" (左侧) | "right" (右侧)
	-- 			position = "bottom",
	-- 			-- 窗口尺寸控制 (分屏下 height 为行数，width 为列宽；浮动下支持小数百分比)
	-- 			size = 0.3,
	-- 		},
	--
	-- 		-------------------------------------------------------------------
	-- 		-- 3. 实时代码预览窗口配置 (Preview Window)
	-- 		-------------------------------------------------------------------
	-- 		preview = {
	-- 			-- 预览窗类型:
	-- 			-- "main"  : 直接在当前正在编辑的主代码缓冲区中高亮对应行进行内联预览
	-- 			-- "split" : 开启一个临时的独立分屏作为代码预览区
	-- 			-- "float" : 弹出一个居中的独立浮动小窗呈现上下文代码
	-- 			type = "main",
	-- 			-- 预览窗口使用的边框线风格: "rounded" (圆角) | "single" | "double" | "shadow"
	-- 			border = "rounded",
	-- 			-- 浮动窗相对定位基准: "editor" (整个终端屏幕) | "win" (关联窗口)
	-- 			relative = "editor",
	-- 			title = "Preview",
	-- 			title_pos = "center",
	-- 			-- 浮动窗口坐标: { 纵向比例, 横向比例 } (0.3 代表距离顶部/左侧 30%)
	-- 			position = { 0.3, 0.3 },
	-- 			-- 浮动预览窗口的实际尺寸: 宽占 60%，高占 50%
	-- 			size = { width = 0.6, height = 0.5 },
	-- 			-- 浮动层级 z-index，设置较高值防止被其他浮窗遮挡
	-- 			zindex = 200,
	-- 		},
	--
	-- 		-------------------------------------------------------------------
	-- 		-- 4. 刷新与防抖节流延迟 (毫秒)
	-- 		-------------------------------------------------------------------
	-- 		throttle = {
	-- 			refresh = 20, -- 收到新结果后等待重新计算的去抖时间
	-- 			update = 10, -- 渲染缓冲区的最小间隔
	-- 			render = 10, -- 窗口绘制防抖延时
	-- 		},
	--
	-- 		-------------------------------------------------------------------
	-- 		-- 5. Trouble 窗口内部快捷键绑定字典 (Keys Table)
	-- 		-------------------------------------------------------------------
	-- 		keys = {
	-- 			["?"] = "help", -- 按问号弹出当前列表内置操作帮助
	-- 			["r"] = "refresh", -- 手动触发强制刷新
	-- 			["R"] = "toggle_refresh", -- 开启/关闭自动同步刷新开关
	-- 			["q"] = "close", -- 按 q 退出并关闭 Trouble 窗口
	-- 			["<esc>"] = "cancel", -- 按 ESC 取消预览或关闭浮窗
	-- 			["<cr>"] = "jump", -- 按回车键跳转到选中代码行
	-- 			["o"] = "jump", -- 按 o 同样跳转到选中位置
	-- 			-- ["<2-leftmouse>"] = "jump", -- 鼠标双击直接跳转到目标代码
	-- 			["<c-s>"] = "jump_split", -- 在水平分割的新分屏中打开目标
	-- 			["<c-v>"] = "jump_vsplit", -- 在垂直分割的新分屏中打开目标
	-- 			["}"] = "next", -- 移动到下一个条目
	-- 			["]]"] = "next", -- 跳转到下一个主要分组/文件节点
	-- 			["{"] = "prev", -- 移动到上一个条目
	-- 			["[["] = "prev", -- 跳转到上一个主要分组/文件节点
	-- 			["dd"] = "delete", -- 从当前列表中临时移除此项（不删磁盘代码）
	-- 			["x"] = "fold_toggle", -- 展开/折叠当前树节点（如折叠某个文件）
	-- 			["za"] = "fold_toggle", -- 展开/折叠（兼容 vim 折叠习惯）
	-- 			["zR"] = "fold_open_all", -- 展开列表中的所有折叠树节点
	-- 			["zM"] = "fold_close_all", -- 折叠列表中的所有分组节点
	-- 			["P"] = "toggle_preview", -- 临时开启/关闭实时代码预览弹窗
	-- 			["i"] = "inspect", -- 检查并打印当前节点内部数据结构信息
	--
	-- 			-- ★ 正确写法：使用包含 action 属性的 table 包装
	-- 			["+"] = {
	-- 				action = function()
	-- 					vim.cmd("vertical resize +5")
	-- 				end,
	-- 				desc = "增加 5 列宽度",
	-- 			},
	--
	-- 			["-"] = {
	-- 				action = function()
	-- 					vim.cmd("vertical resize -5")
	-- 				end,
	-- 				desc = "减少 5 列宽度",
	-- 			},
	-- 		},
	--
	-- 		-------------------------------------------------------------------
	-- 		-- 6. 图标渲染配置 (Icons)
	-- 		-------------------------------------------------------------------
	-- 		icons = {
	-- 			indent = {
	-- 				top = "│ ",
	-- 				middle = "├╴",
	-- 				last = "└╴",
	-- 				fold_open = " ",
	-- 				fold_closed = " ",
	-- 				ws = "  ",
	-- 			},
	-- 			folder_closed = " ",
	-- 			folder_open = " ",
	-- 			kinds = {
	-- 				Array = " ",
	-- 				Boolean = "󰨙 ",
	-- 				Class = " ",
	-- 				Constant = "󰏿 ",
	-- 				Constructor = " ",
	-- 				Enum = " ",
	-- 				EnumMember = " ",
	-- 				Event = " ",
	-- 				Field = "󰜢 ",
	-- 				File = "󰈙 ",
	-- 				Function = "󰊕 ",
	-- 				Interface = " ",
	-- 				Key = " ",
	-- 				Method = "󰆧 ",
	-- 				Module = " ",
	-- 				Namespace = "󰦮 ",
	-- 				Null = " ",
	-- 				Number = "󰎠 ",
	-- 				Object = " ",
	-- 				Operator = " ",
	-- 				Package = " ",
	-- 				Property = " ",
	-- 				String = " ",
	-- 				Struct = "󰙅 ",
	-- 				TypeParameter = " ",
	-- 				Variable = "󰀫 ",
	-- 			},
	-- 		},
	--
	-- 		-------------------------------------------------------------------
	-- 		-- 7. 预设运行模式微调 (Modes Overrides)
	-- 		-------------------------------------------------------------------
	-- 		modes = {
	-- 			-- 项目诊断模式个性化定制
	-- 			diagnostics = {
	-- 				desc = "项目全部 LSP 诊断列表",
	-- 				auto_open = false,
	-- 				filter = {
	-- 					-- 默认不显示已完全解决的条目
	-- 					any = {
	-- 						{ buf = 0 }, -- 优先展示当前文件
	-- 						{ severity = vim.diagnostic.severity.ERROR }, -- 或所有错误项
	-- 					},
	-- 				},
	-- 			},
	--
	-- 			-- 文档大纲模式个性化定制
	-- 			symbols = {
	-- 				desc = "当前文档符号树",
	-- 				mode = "lsp_document_symbols",
	-- 				focus = false,
	-- 				win = {
	-- 					position = "right", -- 大纲模式靠右侧排列更符合 IDE 习惯
	-- 					size = 0.3, -- 固定宽度为 35 列
	-- 				},
	-- 				filter = {
	-- 					-- 过滤掉 Markdown / 代码中冗余的无意义匿名符号
	-- 					["not"] = { ft = "lua", kind = "Package" },
	-- 				},
	-- 			},
	--
	-- 			--  LSP 引用/定义/实现视图模式定制
	-- 			lsp = {
	-- 				desc = "LSP 定义与引用列表",
	-- 				mode = "lsp",
	-- 				focus = true, -- ★ 唤起时光标自动聚焦到该框内
	-- 				win = {
	-- 					position = "right", -- 固定显示在屏幕右侧
	-- 					size = 0.3, -- ★ 占屏幕右侧 30% 宽，彻底解决文字截断问题
	-- 				},
	-- 			},
	-- 		},
	-- 	},
	-- 	config = function(_, opts)
	-- 		require("trouble").setup(opts)
	--
	-- 		-------------------------------------------------------------------
	-- 		-- 8. 保持原配置中的 Lualine Winbar 符号面包屑导航能力
	-- 		-------------------------------------------------------------------
	-- 		local ok_statusline, symbols = pcall(require("trouble").statusline, {
	-- 			mode = "lsp_document_symbols",
	-- 			groups = {},
	-- 			title = false,
	-- 			filter = { range = true },
	-- 			format = "{kind_icon}{symbol.name:Normal}",
	-- 			hl_group = "lualine_b_normal",
	-- 		})
	--
	-- 		if not ok_statusline or not symbols then
	-- 			return
	-- 		end
	--
	-- 		local function winbar_symbols_fallback()
	-- 			if symbols.has and symbols.has() then
	-- 				return symbols.get()
	-- 			end
	-- 			return " "
	-- 		end
	--
	-- 		local lualine_ok, lualine = pcall(require, "lualine")
	-- 		if not lualine_ok then
	-- 			return
	-- 		end
	--
	-- 		local lualine_opts = lualine.get_config() or {}
	-- 		lualine_opts.winbar = lualine_opts.winbar or {}
	-- 		lualine_opts.winbar.lualine_b = lualine_opts.winbar.lualine_b or {}
	--
	-- 		table.insert(lualine_opts.winbar.lualine_b, 1, {
	-- 			winbar_symbols_fallback,
	-- 			color = { gui = "none" },
	-- 			cond = function()
	-- 				return true
	-- 			end,
	-- 		})
	--
	-- 		lualine.setup(lualine_opts)
	-- 	end,
	-- },
}
