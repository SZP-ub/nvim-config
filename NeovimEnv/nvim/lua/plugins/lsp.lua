local function safe_require(name)
	local ok, mod = pcall(require, name)
	if ok then
		return mod
	end
	return nil
end

local function smart_tabout()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_get_current_line()
	local before = line:sub(1, col)
	local after = line:sub(col + 1)

	-- 支持的成对符号定义（可按需增减）
	local pairs_list = {
		{ "(", ")" },
		{ "[", "]" },
		{ "{", "}" },
		{ '"', '"' },
		{ "'", "'" },
		{ "`", "`" },
		{ "$", "$" }, -- 完美兼容 LaTeX / Markdown 行内数学公式
	}

	local nearest_pos = nil

	for _, p in ipairs(pairs_list) do
		local open_pat = vim.pesc(p[1])
		local close_pat = vim.pesc(p[2])

		-- 判定准则：光标左侧存在未闭合的前符号，且右侧存在对应的后符号
		if before:find(open_pat) then
			local pos = after:find(close_pat)
			if pos then
				if not nearest_pos or pos < nearest_pos then
					nearest_pos = pos
				end
			end
		end
	end

	if nearest_pos then
		-- 将光标精准平移至该闭合符号的外侧
		vim.api.nvim_win_set_cursor(0, { row, col + nearest_pos })
		return true
	end
	return false
end

return {
	---------------------------------------------------------------------------
	-- 1. mason.nvim
	---------------------------------------------------------------------------
	{
		"mason-org/mason.nvim",
		event = "VeryLazy",
		opts = {
			ui = {
				width = 0.8,
				height = 0.7,
				icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
			},
		},
		config = function(_, opts)
			local mason = safe_require("mason")
			if mason then
				mason.setup(opts)
			end
		end,
	},

	---------------------------------------------------------------------------
	-- 2. nvim-lspconfig：现代原生 API 写法
	---------------------------------------------------------------------------
	{
		"neovim/nvim-lspconfig",
		event = "VeryLazy",
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local mason_lspconfig = safe_require("mason-lspconfig")
			if not mason_lspconfig then
				return
			end

			-- 全局诊断 UI 配置
			vim.diagnostic.config({
				severity_sort = true,
				underline = { severity = vim.diagnostic.severity.ERROR },
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.INFO] = " ",
						[vim.diagnostic.severity.HINT] = "",
					},
				},
				virtual_text = false,
				float = { border = "rounded", source = "if_many" },
				update_in_insert = false,
			})

			-- LspAttach 按键映射
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("user-lsp-attach", { clear = true }),
				callback = function(event)
					local buf = event.buf
					local client = vim.lsp.get_client_by_id(event.data.client_id)

					local function map(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(
							mode,
							keys,
							func,
							{ buffer = buf, desc = "LSP: " .. (desc or keys), silent = true }
						)
					end

					map("gd", vim.lsp.buf.definition, "跳转到定义")
					map("gi", vim.lsp.buf.implementation, "跳转到实现")
					map("grt", vim.lsp.buf.type_definition, "跳转到类型定义")
					map("grn", vim.lsp.buf.rename, "变量/符号重命名")
					map("gra", vim.lsp.buf.code_action, "代码操作与自动修复", { "n", "x" })
					map("grd", vim.lsp.buf.declaration, "跳转到声明")
					map("[g", vim.diagnostic.goto_prev, "跳转到上一个错误/警告")
					map("]g", vim.diagnostic.goto_next, "跳转到下一个错误/警告")
					map("g[", function()
						vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = true })
					end, "跳转到上一个错误")
					map("g]", function()
						vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = true })
					end, "跳转到下一个错误")

					map("K", function()
						local ufo = safe_require("ufo")
						if ufo then
							local ok, winid = pcall(ufo.peekFoldedLinesUnderCursor)
							if ok and winid and winid ~= 0 then
								return
							end
						end
						vim.lsp.buf.hover()
					end, "Show hover documentation")

					if
						client
						and client.supports_method
						and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, buf)
					then
						local highlight_grp =
							vim.api.nvim_create_augroup("user-lsp-document-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = buf,
							group = highlight_grp,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = buf,
							group = highlight_grp,
							callback = vim.lsp.buf.clear_references,
						})
					end

					if
						client
						and client.supports_method
						and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, buf)
					then
						pcall(vim.lsp.inlay_hint.enable, true, { bufnr = buf })
					end
				end,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local cmp_nvim_lsp = safe_require("cmp_nvim_lsp")
			if cmp_nvim_lsp then
				capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
			end

			vim.lsp.config("*", {
				capabilities = capabilities,
			})

			mason_lspconfig.setup({
				ensure_installed = { "lua_ls", "marksman", "texlab", "basedpyright", "jsonls", "clangd" },
				automatic_installation = true,
			})

			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						workspace = { checkThirdParty = false },
					},
				},
			})

			vim.lsp.enable({ "lua_ls", "marksman", "texlab", "clangd", "jsonls", "basedpyright" })
		end,
	},

	---------------------------------------------------------------------------
	-- 3. nvim-cmp 智能补全（含类 Wilder 风格命令行补全 + 框内幽灵文本）
	---------------------------------------------------------------------------
	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-cmdline",
			"dmitmel/cmp-cmdline-history",
			"hrsh7th/cmp-nvim-lsp-document-symbol",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
			"lukas-reineke/cmp-rg",
			{ "kdheepak/cmp-latex-symbols", ft = { "latex", "tex", "markdown", "markdown_inline" } },
			{ "micangl/cmp-vimtex", ft = { "latex", "tex", "markdown", "markdown_inline" } },
			{ "hrsh7th/cmp-omni", ft = { "tex", "latex" } },
			"rasulomaroff/cmp-bufname",
		},
		config = function()
			local cmp = safe_require("cmp")
			if not cmp then
				return
			end
			local luasnip = safe_require("luasnip")

			if luasnip then
				pcall(require("luasnip.loaders.from_snipmate").lazy_load, {
					paths = { vim.fn.stdpath("config") .. "/snippets" },
				})
			end

			local kind_icons = {
				Text = "󰉿",
				Method = "󰆧",
				Function = "",
				Constructor = "",
				Field = "󰜢",
				Variable = "",
				Class = "",
				Interface = "",
				Module = "",
				Property = "󰜢",
				Unit = "",
				Value = "󰎠",
				Enum = "󰕘",
				Keyword = "󰌋",
				Snippet = "",
				Color = "󰏘",
				File = "",
				Reference = "",
				Folder = "󰉋",
				EnumMember = "",
				Constant = "",
				Struct = "󰙅",
				Event = "",
				Operator = "󰆕",
				TypeParameter = "󰊄",
			}

			cmp.setup({
				snippet = {
					expand = function(args)
						if luasnip then
							luasnip.lsp_expand(args.body)
						end
					end,
				},

				mapping = cmp.mapping.preset.insert({
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip and luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						elseif not smart_tabout() then
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip and luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-p>"] = cmp.mapping.close(),
				}),

				completion = { completeopt = "menu,menuone" },
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, vim_item)
						vim_item.kind = (kind_icons[vim_item.kind] or "")
						vim_item.menu = ({
							luasnip = "[Snip]",
							buffer = "[Buf]",
							path = "[Path]",
							nvim_lsp = "[LSP]",
							vimtex = "[Vimtex]",
							omni = (vim.inspect(vim_item.menu):gsub('%"', "")),
						})[entry.source.name] or ""
						return vim_item
					end,
				},
				sources = cmp.config.sources({
					{ name = "luasnip" },
					{
						name = "buffer",
						option = {
							get_bufnrs = function()
								local bufs = {}
								for _, win in ipairs(vim.api.nvim_list_wins()) do
									bufs[vim.api.nvim_win_get_buf(win)] = true
								end
								return vim.tbl_keys(bufs)
							end,
						},
					},
					{ name = "nvim_lsp" },
					{ name = "path" },
					{
						name = "rg",
						keyword_length = 3,
						option = {
							additional_arguments = "--hidden --max-depth 2",
							pattern = "[a-zA-Z_]+",
							cwd = ".",
							debounce = 500,
							context_before = 2,
							context_after = 4,
						},
					},
					{ name = "latex_symbols", option = { strategy = 0 } },
					{ name = "vimtex" },
					{ name = "omni", trigger_characters = { "{", "\\" } },
					{
						name = "bufname",
						option = {
							current_buf_only = false,
							bufs = function()
								return vim.api.nvim_list_bufs()
							end,
							extractor = function(filename, _)
								return { filename:match("[^.]*") }
							end,
						},
					},
				}),
				experimental = { ghost_text = true },
			})

			-- =================================================================
			-- 类 Wilder 风格命令行补全：视觉 + 状态机 + Noice 框内幽灵文本
			-- =================================================================
			vim.opt.pumheight = 15
			pcall(function()
				vim.opt.wildoptions:append("fuzzy")
			end)

			-- 1. 高亮定义：青色命中字母 + 深灰选中条 + 框内斜体幽灵文本
			local function apply_wilder_cmp_hl()
				pcall(vim.api.nvim_set_hl, 0, "CmpItemAbbrMatch", { fg = "#00afaf", bold = true })
				pcall(vim.api.nvim_set_hl, 0, "CmpItemAbbrMatchFuzzy", { fg = "#00afaf", bold = true })
				pcall(vim.api.nvim_set_hl, 0, "WilderCmpSel", { fg = "#fbf1c7", bg = "#4e4e4e", bold = true })
				pcall(vim.api.nvim_set_hl, 0, "CmpCmdlineGhostText", { fg = "#928374", italic = true })
			end
			apply_wilder_cmp_hl()
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("user-cmp-wilder-hl", { clear = true }),
				callback = apply_wilder_cmp_hl,
			})

			-- 2. Noice Command 浮窗内嵌幽灵文本渲染器
			local cmdline_ghost_ns = vim.api.nvim_create_namespace("user_noice_cmdline_ghost")

			local function get_noice_cmdline_pos()
				local ok, noice_cmdline = pcall(require, "noice.ui.cmdline")
				if ok and noice_cmdline and noice_cmdline.position then
					local buf = noice_cmdline.position.buf
					if buf and vim.api.nvim_buf_is_valid(buf) then
						return buf, noice_cmdline.position.bufpos
					end
				end
				-- 兜底：从浮动窗口中查找 Noice 命令行 buffer
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					local cfg = vim.api.nvim_win_get_config(win)
					if cfg.relative ~= "" then
						local buf = vim.api.nvim_win_get_buf(win)
						if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "noice" then
							return buf, nil
						end
					end
				end
				return nil, nil
			end

			local function flush_buf_redraw(buf)
				if vim.api.nvim__redraw then
					pcall(vim.api.nvim__redraw, { buf = buf, flush = true })
				else
					pcall(vim.cmd, "redraw")
				end
			end

			local function clear_cmdline_ghost()
				local buf = get_noice_cmdline_pos()
				if buf then
					pcall(vim.api.nvim_buf_clear_namespace, buf, cmdline_ghost_ns, 0, -1)
					flush_buf_redraw(buf)
				end
			end

			local function update_cmdline_ghost()
				if vim.api.nvim_get_mode().mode ~= "c" then
					clear_cmdline_ghost()
					return
				end

				local buf, bufpos = get_noice_cmdline_pos()
				if not buf then
					return
				end

				pcall(vim.api.nvim_buf_clear_namespace, buf, cmdline_ghost_ns, 0, -1)

				-- 仅在补全菜单可见、已有高亮选中项、且光标位于行尾时绘制幽灵文本
				if not cmp.visible() then
					flush_buf_redraw(buf)
					return
				end

				local entry = cmp.get_selected_entry()
				if not entry then
					flush_buf_redraw(buf)
					return
				end

				local cmdline = vim.fn.getcmdline() or ""
				if vim.fn.getcmdpos() <= #cmdline then
					flush_buf_redraw(buf)
					return
				end

				local word = entry:get_word() or ""
				if word == "" then
					flush_buf_redraw(buf)
					return
				end

				-- 仅拼接尚未输入的剩余部分；跨字母模糊匹配则用箭头预览完整目标
				local start_col = (entry.offset and entry.offset > 0) and entry.offset or (#cmdline + 1)
				local typed = cmdline:sub(start_col)
				local ghost = ""

				if typed == "" then
					ghost = word
				elseif word:lower():sub(1, #typed) == typed:lower() then
					ghost = word:sub(#typed + 1)
				else
					ghost = "  → " .. word
				end

				if ghost == "" then
					flush_buf_redraw(buf)
					return
				end

				local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
				if #lines == 0 then
					return
				end

				local row = #lines - 1
				local line = lines[#lines] or ""
				local col = #line

				-- 优先对齐 Noice 提供的精确光标字节位置
				if type(bufpos) == "table" then
					if type(bufpos[1]) == "number" and bufpos[1] >= 0 and bufpos[1] < #lines then
						row = bufpos[1]
						line = lines[row + 1] or ""
					end
					if type(bufpos[2]) == "number" and bufpos[2] >= 0 and bufpos[2] <= #line then
						col = bufpos[2]
					end
				end

				pcall(vim.api.nvim_buf_set_extmark, buf, cmdline_ghost_ns, row, col, {
					virt_text = { { ghost, "CmpCmdlineGhostText" } },
					virt_text_pos = "inline",
					hl_mode = "combine",
				})
				flush_buf_redraw(buf)
			end

			local function schedule_cmdline_ghost()
				vim.defer_fn(update_cmdline_ghost, 15)
			end

			local ghost_grp = vim.api.nvim_create_augroup("user-cmp-cmdline-ghost", { clear = true })
			vim.api.nvim_create_autocmd("CmdlineChanged", {
				group = ghost_grp,
				callback = schedule_cmdline_ghost,
			})
			vim.api.nvim_create_autocmd("CmdlineLeave", {
				group = ghost_grp,
				callback = clear_cmdline_ghost,
			})
			cmp.event:on("menu_opened", schedule_cmdline_ghost)
			cmp.event:on("menu_closed", clear_cmdline_ghost)

			-- 3. 弹窗样式：圆角边框 + 滚动条 + 选中行高亮
			local cmdline_window = {
				completion = cmp.config.window.bordered({
					border = "rounded",
					scrollbar = true,
					winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:WilderCmpSel,Search:None",
					side_padding = 1,
				}),
			}

			-- 4. 左侧图标与来源标签
			local devicons = safe_require("nvim-web-devicons")
			local cmdline_formatting = {
				fields = { "kind", "abbr", "menu" },
				format = function(entry, vim_item)
					local source = entry.source.name
					if source == "path" then
						local label = vim_item.abbr or ""
						if label:sub(-1) == "/" or label:sub(-1) == "\\" then
							vim_item.kind = "󰉋"
							vim_item.kind_hl_group = "Directory"
						elseif devicons then
							local filename = label:match("[^/\\]+$") or label
							local ext = filename:match("%.([^%.]+)$") or ""
							local icon, hl = devicons.get_icon(filename, ext, { default = true })
							vim_item.kind = icon or ""
							vim_item.kind_hl_group = hl
						else
							vim_item.kind = ""
						end
						vim_item.menu = "[Path]"
					elseif source == "cmdline" then
						vim_item.kind = ""
						vim_item.kind_hl_group = "CmpItemAbbrMatch"
						vim_item.menu = "[Cmd]"
					elseif source == "cmdline_history" then
						vim_item.kind = ""
						vim_item.kind_hl_group = "Comment"
						vim_item.menu = "[Hist]"
					elseif source == "nvim_lsp_document_symbol" then
						vim_item.kind = kind_icons[vim_item.kind] or "󰌗"
						vim_item.menu = "[Sym]"
					elseif source == "buffer" then
						vim_item.kind = ""
						vim_item.kind_hl_group = "CmpItemAbbrMatch"
						vim_item.menu = "[Find]"
					else
						vim_item.kind = ""
						vim_item.menu = ""
					end
					return vim_item
				end,
			}

			-- 5. 全量模糊匹配策略
			local cmdline_matching = {
				disallow_fuzzy_matching = false,
				disallow_fullfuzzy_matching = false,
				disallow_partial_fuzzy_matching = false,
				disallow_partial_matching = false,
				disallow_prefix_unmatching = false,
				disallow_symbol_nonprefix_matching = false,
			}

			-- 6. 历史记录降噪过滤器
			local function filter_short_history(entry)
				local text = vim.trim(entry:get_word() or "")
				if #text <= 3 and text:match("^[wqax!]+$") then
					return false
				end
				return true
			end

			-- 7. 按键状态机：浏览时只更新幽灵预览，按 <Right> 或 <CR> 采纳
			local cmdline_mapping = cmp.mapping.preset.cmdline({
				["<Tab>"] = {
					c = function()
						if cmp.visible() then
							cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
						else
							cmp.complete()
						end
						schedule_cmdline_ghost()
					end,
				},
				["<S-Tab>"] = {
					c = function()
						if cmp.visible() then
							cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
						else
							cmp.complete()
						end
						schedule_cmdline_ghost()
					end,
				},
				["<Down>"] = {
					c = function(fallback)
						if cmp.visible() then
							cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
							schedule_cmdline_ghost()
						else
							fallback()
						end
					end,
				},
				["<Up>"] = {
					c = function(fallback)
						if cmp.visible() then
							cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
							schedule_cmdline_ghost()
						else
							fallback()
						end
					end,
				},
				["<Right>"] = {
					c = function(fallback)
						if cmp.visible() and cmp.get_selected_entry() then
							cmp.confirm({ select = false })
							clear_cmdline_ghost()
						else
							fallback()
						end
					end,
				},
				["<CR>"] = {
					c = function(fallback)
						if cmp.visible() and cmp.get_selected_entry() then
							cmp.confirm({ select = false })
							clear_cmdline_ghost()
						else
							if cmp.visible() then
								cmp.close()
							end
							clear_cmdline_ghost()
							fallback()
						end
					end,
				},
				["<C-e>"] = {
					c = function(fallback)
						clear_cmdline_ghost()
						if cmp.visible() then
							cmp.abort()
						else
							fallback()
						end
					end,
				},
			})

			-- 命令行搜索补全（/ 与 ?）
			cmp.setup.cmdline({ "/", "?" }, {
				completion = { completeopt = "menu,menuone,noselect" },
				window = cmdline_window,
				formatting = cmdline_formatting,
				matching = cmdline_matching,
				mapping = cmdline_mapping,
				sources = cmp.config.sources({
					{ name = "nvim_lsp_document_symbol", priority = 1000, max_item_count = 10 },
					{
						name = "bufname",
						option = {
							current_buf_only = false,
							bufs = function()
								return vim.api.nvim_list_bufs()
							end,
							extractor = function(filename, _)
								return { filename:match("[^.]*") }
							end,
						},
					},
					{ name = "buffer", priority = 700, max_item_count = 10 },
				}),
			})

			-- 命令行指令与路径补全（:）
			cmp.setup.cmdline(":", {
				completion = { completeopt = "menu,menuone,noselect" },
				window = cmdline_window,
				formatting = cmdline_formatting,
				matching = cmdline_matching,
				mapping = cmdline_mapping,
				sources = cmp.config.sources({
					{ name = "path", priority = 1000 },
				}, {

					{
						name = "bufname",
						option = {
							current_buf_only = false,
							bufs = function()
								return vim.api.nvim_list_bufs()
							end,
							extractor = function(filename, _)
								return { filename:match("[^.]*") }
							end,
						},
					},
					{
						name = "cmdline",
						priority = 900,
						option = { ignore_cmds = { "Man", "!" } },
					},
					{
						name = "cmdline_history",
						priority = 500,
						max_item_count = 8,
						entry_filter = filter_short_history,
					},
					-- {
					-- 	name = "rg",
					-- 	keyword_length = 3,
					-- 	option = {
					-- 		additional_arguments = "--hidden --max-depth 2",
					-- 		pattern = "[a-zA-Z_]+",
					-- 		cwd = ".",
					-- 		debounce = 500,
					-- 		context_before = 2,
					-- 		context_after = 4,
					-- 	},
					-- },
					{ name = "nvim_lsp" },
				}),
			})
		end,
	},
}
