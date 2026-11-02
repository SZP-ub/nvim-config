---@diagnostic disable: undefined-global
return {

	-- 文件图标（供 lualine / 其他插件使用）
	{
		"nvim-tree/nvim-web-devicons",
		lazy = true,
		config = function()
			require("nvim-web-devicons").setup({
				override = {
					copilot = {
						icon = "",
						color = "#cba6f7", -- Catppuccin.mocha.mauve
						name = "Copilot",
					},
					markdown = {
						icon = "",
						color = "#498ba7",
						name = "Markdown",
					},
					bash = {
						icon = "",
						name = "Bash",
					},
					pdf = {
						icon = "",
						name = "Pdf",
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

			-- 在 colorscheme 切换时设置高亮组
			hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
				vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#cc241a" })
				vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#d79921" })
				vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#458587" })
				vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#d35307" })
				vim.api.nvim_set_hl(0, "RainbowCGreen", { fg = "#689d6a" })
				vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
				vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })

				-- 活动/当前作用域高亮：纯黑、粗体并下划线（snacks.scope.underline 等价）
				-- 注意：终端对 bold/underline 支持不一，竖线字符可能看不明显
				vim.api.nvim_set_hl(0, "RainbowActive", { bold = true, underline = true })
			end)

			require("ibl").setup({
				indent = {
					highlight = highlight, -- 多色普通缩进线
					-- char = "║│", -- 若终端看不出粗体，可换为 "┃"
					char = "║", -- 若终端看不出粗体，可换为 "┃"
				},
				scope = {
					enabled = true, -- 显示当前 scope
					show_start = true, -- 显示作用域开始处的缩进线
					highlight = { "RainbowActive" }, -- 使用上面定义的带下划线高亮
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

	-- 状态栏
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			-- 常量与缓存
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

			-- 安全刷新 lualine（避免 E492）
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

			-- devicons -> MyBoldHL（简化）
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

			-- 统一应用其他高亮（a/z/tabline/center 等）
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

			-- 诊断组件：拆成 4 个独立组件，由 lualine 管理颜色（只设置 fg）
			local diag_error = {
				function()
					local d = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
					local n = #d
					if n > 0 then
						return " " .. n
						-- return " " .. n
					end
					return ""
				end,
				cond = hide_in_width,
				color = { fg = "#c00058" }, -- 错误前景
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
				color = { fg = "#ffa500" }, -- 警告前景（改为橙色 #ffa500）
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
				color = { fg = "#d3d3d3" }, -- 信息前景
			}
			local diag_hint = {
				function()
					local d = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
					local n = #d
					if n > 0 then
						-- return " " .. n
						return "" .. n
						-- return "󰌶 " .. n
					end
					return ""
				end,
				cond = hide_in_width,
				color = { fg = "#d3d3d3" }, -- 提示前景
			}

			-- diff（使用 gitsigns 提供的数据）
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

			-- bufnr_name（devicons 支持，简洁缓存）
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

					-- 针对 Markdown (md 或 markdown) 强制设置图标与前景色（保持背景不变）
					local is_markdown = (ext == "md" or ext == "markdown")
					if is_markdown then
						cached.icon = ""
						-- 不依赖 devicons 的 hl，后面直接使用自定义颜色
					end

					local icon = cached.icon or ""
					local hl_name = "LualineDevIconHL_" .. sanitize_hlname(ext ~= "" and ext or "none")
					if not devicon_hl_cache[hl_name] then
						local fg_hex = "#8ec07c"
						local ext_hl = cached.hl
						-- 如果是 Markdown，就使用指定的前景色 #498ba7
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

			-- inactive center（把高亮放在 %= 前）
			local function inactive_center()
				return "%=" .. "%#LualineInactiveCenterHL#%=" .. "   " .. vim.fn.winnr() .. "%=%*"
			end

			-- autocmd：在主题改变 / 进入 buffer / resize 时重新应用高亮与刷新
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

			-- 先预应用一次（setup 之前）
			apply_highlights()

			-- 构造/加载 theme_tbl 并覆盖 a.bg
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

			-- lualine setup（把 theme_tbl 传入）
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
					-- 在 lualine_x 中按顺序放入 4 个诊断组件（颜色已在 component.color 中设置）
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
					lualine_b = { diag_error }, -- 你也可以在 inactive 放入其它 diag 组件
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

			-- setup 后再应用一次高亮作为保险，并刷新
			apply_highlights()
			safe_lualine_update()
		end,
	},
}
