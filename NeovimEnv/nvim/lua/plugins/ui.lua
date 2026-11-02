---@diagnostic disable: undefined-global
return {

	{
		"mhinz/vim-startify",
		lazy = false,
		priority = 1000,
		init = function()
			-- 1. 自定义顶部 Header（左上角 / 居中小羊驼图案）
			-- vim.g.startify_custom_header = {
			-- 	[[    \   /\_/\    ]],
			-- 	[[     \ ( o.o )   ]],
			-- 	[[       (  -  )   ]],
			-- 	[[       /|   |\   ]],
			-- 	[[      (_|_|_|_)  ]],
			-- 	[[   --- STARTIFY --- ]],
			-- 	"",
			-- }

			-- 2. 面板展示模块及顺序（最近打开文件、当前目录文件、书签、会话等）
			vim.g.startify_lists = {
				{ type = "files", header = { "   MRU 最近打开文件" } },
				{ type = "dir", header = { "   DIR 当前目录文件" } },
				{ type = "sessions", header = { "   SESSIONS 会话" } },
				{ type = "bookmarks", header = { "   BOOKMARKS 快速书签" } },
				{ type = "commands", header = { "   COMMANDS 快捷命令" } },
			}

			-- 3. 自定义快速书签
			vim.g.startify_bookmarks = {
				{ c = vim.fn.stdpath("config") .. "/init.lua" },
			}

			-- 4. 目录与行为设置
			vim.g.startify_change_to_dir = 1 -- 打开文件时自动 cd 到该文件所在目录
			vim.g.startify_change_to_vcs_root = 1 -- 如果是 Git 仓库，自动 cd 到仓库根目录
			vim.g.startify_session_persistence = 1 -- 退出时自动更新保存会话
			vim.g.startify_enable_special = 0 -- 关闭 <empty buffer> 和 <quit> 冗余选项
		end,
	},

	-- {
	-- 	"oxidescheme/nvim",
	-- 	name = "oxide",
	-- 	lazy = false,
	-- 	priority = 1000,
	-- 	config = function()
	-- 		require("oxide").setup()
	-- 		vim.cmd.colorscheme("oxide")
	-- 	end,
	-- },

	{
		"sainnhe/gruvbox-material",
		-- lazy = false,
		event = "VeryLazy",
		priority = 1000,
		config = function()
			-- 开启终端真彩色
			vim.opt.termguicolors = true

			-- 选择深色模式（"dark"）或浅色模式（"light"）
			vim.opt.background = "light"

			-- 材质对比度配置（可选）：'hard' | 'medium' | 'soft'，默认推荐 medium
			vim.g.gruvbox_material_background = "medium"
			-- 是否启用漂亮的斜体代码修饰（可选）
			vim.g.gruvbox_material_enable_italic = 1

			-- 应用主题
			vim.cmd([[colorscheme gruvbox-material]])
		end,
	},

	-- {
	-- 	"machakann/vim-colorscheme-tatami",
	-- 	event = "VeryLazy",
	-- 	-- lazy = false,
	-- 	priority = 1000,
	-- 	config = function()
	-- 		vim.opt.background = "light" -- tatami 是浅色榻榻米绿风格
	-- 		vim.cmd([[colorscheme tatami]])
	-- 	end,
	-- },

	-- 文件图标（供 lualine / 状态栏使用）
	{
		"nvim-tree/nvim-web-devicons",
		lazy = true,
		config = function()
			require("nvim-web-devicons").setup({
				override = {
					copilot = {
						icon = "",
						color = "#cba6f7",
						name = "Copilot",
					},
					markdown = {
						icon = "",
						color = "#498ba7",
						name = "Markdown",
					},
					pdf = {
						icon = "",
						name = "Pdf",
					},
					bash = {
						icon = "",
						name = "Bash",
					},
				},
				color_icons = true,
				default = true,
			})
		end,
		enabled = vim.g.have_nerd_font,
	},

	-- 缩进线
	{
		"lukas-reineke/indent-blankline.nvim",
		event = "VeryLazy",
		config = function()
			local hooks = require("ibl.hooks")

			local highlight = {
				"RainbowRed",
				"RainbowYellow",
				"RainbowGreen",
				"RainbowOrange",
				"RainbowCGreen",
				"RainbowViolet",
				"RainbowCyan",
			}

			hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
				vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#cc241a" })
				vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#d79921" })
				vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#458587" })
				vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#d35307" })
				vim.api.nvim_set_hl(0, "RainbowCGreen", { fg = "#689d6a" })
				vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
				vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })

				vim.api.nvim_set_hl(0, "RainbowActive", { bold = true, underline = true })
			end)

			require("ibl").setup({
				indent = {
					highlight = highlight,
					char = "║",
				},
				scope = {
					enabled = true,
					show_start = true,
					highlight = { "RainbowActive" },
				},
				exclude = {
					filetypes = {
						"markdown",
						"help",
						"startify",
						"dashboard",
						"lazy",
						"neo-tree",
						"Trouble",
						"alpha",
						"snippets",
					},
				},
			})

			hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
		end,
	},

	-- 状态栏 (针对 Markdown 具有专属图标和着色支持)
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local WINWIDTH_THRESHOLD = 85
			local hide_in_width = function()
				return vim.fn.winwidth(0) > WINWIDTH_THRESHOLD
			end

			local ok_devicons, devicons = pcall(require, "nvim-web-devicons")
			local devicons_cache = {}
			local devicon_hl_cache = {}

			local ACTIVE_BG = "#83a598"
			local INACTIVE_BG = "#7c6f64"
			local TABLINE_BG = "#A5A8A6"

			local function safe_lualine_update()
				local ok, lualine = pcall(require, "lualine")
				if ok and lualine then
					if type(lualine.refresh) == "function" then
						pcall(lualine.refresh)
						return
					end
					if type(lualine.update) == "function" then
						pcall(lualine.update)
						return
					end
				end
				if vim.fn.exists(":LualineUpdate") == 2 then
					pcall(vim.cmd, "LualineUpdate")
				end
			end

			local function set_myboldhl_from_devicons()
				if not ok_devicons then
					pcall(vim.api.nvim_set_hl, 0, "MyBoldHL", { fg = "#ff8800", bold = true })
					return
				end
				local name = vim.fn.expand("%:t")
				local ext = vim.fn.expand("%:e")
				local _, hl_group = devicons.get_icon(name, ext, { default = true })
				if hl_group and vim.fn.hlexists(hl_group) == 1 then
					local ok2, hl = pcall(vim.api.nvim_get_hl_by_name, hl_group, true)
					if ok2 and hl and hl.foreground then
						local color = string.format("#%06x", hl.foreground)
						pcall(vim.api.nvim_set_hl, 0, "MyBoldHL", { fg = color, bold = true })
						return
					end
				end
				pcall(vim.api.nvim_set_hl, 0, "MyBoldHL", { fg = "#ff8800", bold = true })
			end

			local function apply_highlights()
				set_myboldhl_from_devicons()

				pcall(vim.api.nvim_set_hl, 0, "lualine_a_normal", { bg = ACTIVE_BG })
				pcall(vim.api.nvim_set_hl, 0, "lualine_a_inactive", { bg = INACTIVE_BG })

				local okz, z_normal = pcall(vim.api.nvim_get_hl_by_name, "lualine_z_normal", true)
				local z_fg = (okz and z_normal and z_normal.foreground) and string.format("#%06x", z_normal.foreground)
					or "#ffffff"
				pcall(vim.api.nvim_set_hl, 0, "LualineZActive", { fg = z_fg, bg = INACTIVE_BG })
				pcall(vim.api.nvim_set_hl, 0, "LualineZInactive", { fg = z_fg, bg = INACTIVE_BG })

				pcall(vim.api.nvim_set_hl, 0, "TabLine", { bg = TABLINE_BG })
				pcall(vim.api.nvim_set_hl, 0, "TabLineSel", { bg = TABLINE_BG })
				pcall(vim.api.nvim_set_hl, 0, "TabLineFill", { bg = TABLINE_BG })
				pcall(vim.api.nvim_set_hl, 0, "lualine_tabline", { bg = TABLINE_BG })
				pcall(vim.api.nvim_set_hl, 0, "lualine_tabline_sel", { bg = TABLINE_BG })
				pcall(vim.api.nvim_set_hl, 0, "lualine_tabline_fill", { bg = TABLINE_BG })

				pcall(
					vim.api.nvim_set_hl,
					0,
					"LualineInactiveCenterHL",
					{ fg = "#f9f5d7", bg = "#fdaac0", bold = true }
				)
			end

			local diag_error = {
				function()
					local d = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
					local n = #d
					if n > 0 then
						return " " .. n
					end
					return ""
				end,
				cond = hide_in_width,
				color = { fg = "#c00058" },
			}
			local diag_warn = {
				function()
					local d = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
					local n = #d
					if n > 0 then
						return " " .. n
					end
					return ""
				end,
				cond = hide_in_width,
				color = { fg = "#ffa500" },
			}
			local diag_info = {
				function()
					local d = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
					local n = #d
					if n > 0 then
						return " " .. n
					end
					return ""
				end,
				cond = hide_in_width,
				color = { fg = "#d3d3d3" },
			}
			local diag_hint = {
				function()
					local d = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
					local n = #d
					if n > 0 then
						return "" .. n
					end
					return ""
				end,
				cond = hide_in_width,
				color = { fg = "#d3d3d3" },
			}

			local diff = {
				function()
					local gss = vim.b.gitsigns_status_dict
					if not gss then
						return ""
					end
					local parts = {}
					if gss.added and gss.added > 0 then
						table.insert(parts, " " .. gss.added)
					end
					if gss.changed and gss.changed > 0 then
						table.insert(parts, " " .. gss.changed)
					end
					if gss.removed and gss.removed > 0 then
						table.insert(parts, " " .. gss.removed)
					end
					if #parts == 0 then
						return ""
					end
					return table.concat(parts, "  ")
				end,
				cond = hide_in_width,
			}

			local function sanitize_hlname(s)
				return s:gsub("%W", "_")
			end
			local bufnr_name = {
				function()
					local bufnr = vim.api.nvim_get_current_buf()
					local name = vim.fn.expand("%:t")
					local ext = vim.fn.expand("%:e")
					local cached = devicons_cache[ext]
					if not cached then
						if ok_devicons then
							local icon, hl = devicons.get_icon(name, ext, { default = true })
							cached = { icon = icon or "", hl = hl }
						else
							cached = { icon = "", hl = nil }
						end
						devicons_cache[ext] = cached
					end

					local is_markdown = (ext == "md" or ext == "markdown")
					if is_markdown then
						cached.icon = ""
					end

					local icon = cached.icon or ""
					local hl_name = "LualineDevIconHL_" .. sanitize_hlname(ext ~= "" and ext or "none")
					if not devicon_hl_cache[hl_name] then
						local fg_hex = "#8ec07c"
						local ext_hl = cached.hl
						if is_markdown then
							fg_hex = "#498ba7"
						else
							if ext_hl and vim.fn.hlexists(ext_hl) == 1 then
								local ok2, hl = pcall(vim.api.nvim_get_hl_by_name, ext_hl, true)
								if ok2 and hl and hl.foreground then
									fg_hex = string.format("#%06x", hl.foreground)
								end
							end
						end
						pcall(vim.api.nvim_set_hl, 0, hl_name, { fg = fg_hex, bg = INACTIVE_BG, bold = false })
						devicon_hl_cache[hl_name] = true
					end
					local text = string.format("%d %s", bufnr, name)
					local is_active_win = (vim.api.nvim_get_current_win() == vim.fn.win_getid(vim.fn.winnr()))
					if is_active_win then
						return "%#" .. hl_name .. "#" .. icon .. " " .. "%#LualineZActive#" .. text .. "%*"
					else
						return "%#" .. hl_name .. "#" .. icon .. " " .. "%#LualineZInactive#" .. text .. "%*"
					end
				end,
			}

			local function inactive_center()
				return "%=" .. "%#LualineInactiveCenterHL#%=" .. "   " .. vim.fn.winnr() .. "%=%*"
			end

			local aug = vim.api.nvim_create_augroup("LualineCustom", { clear = true })
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = aug,
				callback = function()
					apply_highlights()
				end,
			})
			vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter", "BufWinEnter" }, {
				group = aug,
				callback = function()
					devicons_cache = {}
					devicon_hl_cache = {}
					apply_highlights()
					safe_lualine_update()
				end,
			})
			vim.api.nvim_create_autocmd("VimResized", {
				group = aug,
				callback = function()
					apply_highlights()
					safe_lualine_update()
				end,
			})

			apply_highlights()

			local chosen_theme = vim.env.LUALINE_THEME or "gruvbox_light"
			local theme_tbl = nil
			local ok_theme, loaded = pcall(require, "lualine.themes." .. chosen_theme)
			if ok_theme and type(loaded) == "table" then
				theme_tbl = loaded
			else
				theme_tbl = {
					normal = {
						a = { fg = "#ffffff", bg = ACTIVE_BG },
						b = { fg = "#ffffff", bg = INACTIVE_BG },
						c = { fg = "#ffffff", bg = INACTIVE_BG },
					},
					insert = {
						a = { fg = "#000000", bg = ACTIVE_BG },
						b = { fg = "#000000", bg = INACTIVE_BG },
						c = { fg = "#000000", bg = INACTIVE_BG },
					},
					visual = {
						a = { fg = "#000000", bg = ACTIVE_BG },
						b = { fg = "#000000", bg = INACTIVE_BG },
						c = { fg = "#000000", bg = INACTIVE_BG },
					},
					replace = {
						a = { fg = "#000000", bg = ACTIVE_BG },
						b = { fg = "#000000", bg = INACTIVE_BG },
						c = { fg = "#000000", bg = INACTIVE_BG },
					},
					inactive = {
						a = { fg = "#ffffff", bg = INACTIVE_BG },
						b = { fg = "#ffffff", bg = INACTIVE_BG },
						c = { fg = "#ffffff", bg = INACTIVE_BG },
					},
				}
			end
			theme_tbl.normal = theme_tbl.normal or {}
			theme_tbl.insert = theme_tbl.insert or {}
			theme_tbl.visual = theme_tbl.visual or {}
			theme_tbl.replace = theme_tbl.replace or {}
			theme_tbl.normal.a = theme_tbl.normal.a or {}
			theme_tbl.insert.a = theme_tbl.insert.a or {}
			theme_tbl.visual.a = theme_tbl.visual.a or {}
			theme_tbl.replace.a = theme_tbl.replace.a or {}
			theme_tbl.normal.a.bg = ACTIVE_BG
			theme_tbl.insert.a.bg = ACTIVE_BG
			theme_tbl.visual.a.bg = ACTIVE_BG
			theme_tbl.replace.a.bg = ACTIVE_BG

			require("lualine").setup({
				options = {
					icons_enabled = true,
					theme = theme_tbl,
					always_divide_middle = true,
					globalstatus = false,
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
					disabled_filetypes = { "alpha", "neo-tree" },
				},

				sections = {
					lualine_a = { {
						"mode",
						fmt = function(s)
							return " " .. s
						end,
					} },
					lualine_b = { { "branch", icon = "" }, { "filename", cond = hide_in_width } },
					lualine_c = {},
					lualine_x = {
						diag_error,
						diag_warn,
						diag_info,
						diag_hint,
						diff,
						{ "encoding", cond = hide_in_width },
					},
					lualine_y = { { "location", cond = hide_in_width }, "progress" },
					lualine_z = { bufnr_name },
				},

				inactive_sections = {
					lualine_a = { {
						"mode",
						fmt = function(s)
							return " " .. s
						end,
					} },
					lualine_b = { diag_error },
					lualine_c = { inactive_center },
					lualine_x = {},
					lualine_y = { "progress" },
					lualine_z = { bufnr_name },
				},

				tabline = {
					lualine_a = {
						function()
							return "tabs"
						end,
					},
					lualine_b = {},
					lualine_c = {
						function()
							local tabs = {}
							for i = 1, vim.fn.tabpagenr("$") do
								local winnr = vim.fn.tabpagewinnr(i)
								local buflist = vim.fn.tabpagebuflist(i)
								local bufnr = buflist[winnr]
								local name = vim.fn.bufname(bufnr)
								name = name ~= "" and vim.fn.fnamemodify(name, ":t") or "[no name]"
								local modified = false
								for _, b in ipairs(buflist) do
									if vim.fn.getbufvar(b, "&modified") == 1 then
										modified = true
										break
									end
								end
								local current = (i == vim.fn.tabpagenr()) and "%#TabLineSel#" or "%#TabLine#"
								table.insert(
									tabs,
									string.format("%s %d %s %s", current, i, name, modified and " [+]" or "")
								)
							end
							return table.concat(tabs)
						end,
					},
					lualine_x = {},
					lualine_y = {},
					lualine_z = { "buffers" },
				},

				extensions = { "fugitive" },
			})

			apply_highlights()
			safe_lualine_update()
		end,
	},

	---------------------------------------------------------------------------
	-- fidget.nvim（专精 LSP 运行进度指示，不越权接管系统通知）
	---------------------------------------------------------------------------
	-- {
	-- 	"j-hui/fidget.nvim",
	-- 	event = "LspAttach",
	-- 	opts = {
	-- 		-- =================================================================
	-- 		-- 1. LSP 运行进度指示 (texlab / lua_ls / marksman 等)
	-- 		-- =================================================================
	-- 		progress = {
	-- 			poll_rate = 0, -- 仅在收到 LSP 消息时更新，节能
	-- 			suppress_on_insert = true, -- 插入模式下静默新消息，避免打扰输入
	-- 			ignore_done_already = true, -- 忽略已完成的瞬态闪烁任务
	-- 			ignore_empty_message = true, -- 过滤空消息
	-- 			ignore = {},
	--
	-- 			display = {
	-- 				render_limit = 10,
	-- 				done_ttl = 2.5,
	-- 				done_icon = "✔",
	-- 				done_style = "Constant",
	-- 				progress_icon = { "dots" },
	-- 				progress_style = "WarningMsg",
	-- 				group_style = "Title",
	-- 				icon_style = "Question",
	-- 				priority = 30,
	-- 				skip_history = true,
	--
	-- 				format_message = function(msg)
	-- 					if msg.percentage then
	-- 						return string.format("%s (%.0f%%)", msg.title or "", msg.percentage)
	-- 					end
	-- 					return msg.title or msg.message or "Running..."
	-- 				end,
	--
	-- 				overrides = {
	-- 					texlab = { name = "TeXLab (LaTeX)" },
	-- 					lua_ls = { name = "Lua-LS" },
	-- 					marksman = { name = "Marksman (Markdown)" },
	-- 				},
	-- 			},
	--
	-- 			lsp = {
	-- 				progress_ringbuf_size = 0,
	-- 				log_handler = false,
	-- 			},
	-- 		},
	--
	-- 		-- =================================================================
	-- 		-- 2. 通知中心：彻底关闭 override_vim_notify，杜绝与 Noice 冲突
	-- 		-- =================================================================
	-- 		notification = {
	-- 			-- 关键：设为 false，不篡改全局 vim.notify，交给 noice.nvim 管理
	-- 			override_vim_notify = false,
	-- 		},
	--
	-- 		-- =================================================================
	-- 		-- 3. 内部调试日志
	-- 		-- =================================================================
	-- 		logger = {
	-- 			enable = false,
	-- 		},
	-- 	},
	-- },

	-- VS Code风格滚动条
	-- {
	-- "mihovilrak/scroll.nvim",
	-- -- event = "VeryLazy",
	-- event = { "BufReadPost", "BufNewFile" },
	-- opts = {
	-- 	enabled = true,
	--
	-- 	-- 垂直滚动条
	-- 	vertical = {
	-- 		enabled = true,
	-- 		width = 1, -- 轨道列宽
	-- 		char = "█", -- 滑块字符
	-- 		-- track_char = "│", -- 轨道字符；若设为 " " 则轨道不可见
	-- 		track_char = "║",
	-- 	},
	--
	-- 	-- 水平滚动条
	-- 	horizontal = {
	-- 		enabled = true,
	-- 		height = 1,
	-- 		char = "▄", -- 半高字符，厚度与 1 列的垂直滑块相匹配
	-- 		track_char = "─",
	-- 	},
	--
	-- 	visibility = "auto", -- "auto" (按需自动显隐) | "always" | "hover"
	-- 	hide_delay = 2500, -- 停止操作后隐藏的延迟时间 (ms)
	--
	-- 	-- 轨道标记（Overview ruler）
	-- 	-- 单列轨道上若存在冲突，优先级为: error > warning > search > info > hint > git > scope
	-- 	marks = {
	-- 		enabled = true,
	-- 		diagnostics = {
	-- 			enabled = true,
	-- 			char = "━",
	-- 			severity = nil, -- 传给 vim.diagnostic.get，如 { min = vim.diagnostic.severity.WARN }
	-- 		},
	-- 		git = {
	-- 			enabled = true,
	-- 			char = "▌",
	-- 			max_lines = 20000, -- 未安装 gitsigns 时，超过该行数跳过 diff 计算
	-- 			debounce = 200,
	-- 		},
	-- 		search = {
	-- 			enabled = true,
	-- 			char = "━", -- 当 'hlsearch' 高亮时显示
	-- 		},
	-- 		scope = {
	-- 			enabled = true,
	-- 			char = "─", -- 当前光标所在代码块的首尾标记
	-- 			-- 注意：已移除原文档中的 "..." 省略号，防止 Lua 解析报错
	-- 			node_types = { "function", "method", "if", "else", "for", "while" },
	-- 		},
	-- 	},
	--
	-- 	-- 盲文小地图（默认关闭）
	-- 	minimap = {
	-- 		enabled = false,
	-- 		width = 10, -- 列宽（包含 1 列 git gutter）
	-- 		columns_per_dot = 3,
	-- 		colors = true, -- true 为使用缓冲区语法色彩；false 为统一使用 ScrollMinimap 高亮组
	-- 		min_window_width = 80, -- 窗口小于该宽度时不渲染
	-- 		git = true,
	-- 		git_char = "▎",
	-- 		winblend = 0,
	-- 		autohide = false,
	-- 		cursor = true, -- 在光标所在行下方添加下划线
	-- 		-- 排除小地图的启动界面与仪表盘
	-- 		excluded_filetypes = { "snacks_dashboard", "dashboard", "alpha", "ministarter" },
	-- 		enabled_for = nil, -- 自定义判定函数: function(buf, win) -> boolean|nil
	-- 		dodge = {
	-- 			margin = true,
	-- 			hide = true, -- 光标或选区位于小地图下方时自动隐藏
	-- 		},
	-- 	},
	--
	-- 	-- 侧边栏文件树滚动条
	-- 	explorer = {
	-- 		enabled = true,
	-- 		filetypes = { "neo-tree", "NvimTree" },
	-- 		snacks = true, -- 支持 Snacks explorer
	-- 		horizontal = true,
	-- 		min_width = 8,
	-- 	},
	--
	-- 	winblend = 30, -- 浮动窗口透明度: 0 为不透明，100 为完全透明
	-- 	zindex = 40, -- 堆叠层级：低于补全弹窗，高于正文
	-- 	mouse = false, -- 支持鼠标点击跳转与拖拽滑块
	--
	-- 	excluded_filetypes = { "help", "qf", "NvimTree", "neo-tree", "TelescopePrompt", "lazy", "mason" },
	-- 	excluded_buftypes = { "terminal", "prompt", "nofile", "quickfix" },
	--
	-- 	min_width = 20, -- 忽略小于此宽度的窗口
	-- 	min_height = 5,
	--
	-- 	exact_measure_max_lines = 10000,
	-- },
	-- },
}
