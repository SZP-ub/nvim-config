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

					-- 跳转到定义处（如光标下的函数实现、变量被创建赋值的地方）
					map("gd", vim.lsp.buf.definition, "跳转到定义")

					-- 跳转到接口的具体实现（面向对象语言中，从抽象接口/类跳转到具体实现它的代码处）
					map("gi", vim.lsp.buf.implementation, "跳转到实现")

					-- 跳转到类型定义处（跳转到光标所在变量的类型声明/类定义，而非变量本身）
					map("grt", vim.lsp.buf.type_definition, "跳转到类型定义")

					-- 符号重命名（安全重命名函数、变量或类名，整个项目相关引用会同步修改）
					map("grn", vim.lsp.buf.rename, "变量/符号重命名")

					-- 快速修复 / 代码操作（弹出当前报错或警告的自动修复方案，支持普通模式与可视模式）
					map("gra", vim.lsp.buf.code_action, "代码操作与自动修复", { "n", "x" })

					-- 跳转到声明处（常见于 C/C++ 等头文件与源文件分离的语言，跳到声明原型处）
					map("grd", vim.lsp.buf.declaration, "跳转到声明")

					-- 跳转到上一个诊断信息（移动到上一个报错 Error 或警告 Warning 处）
					map("[g", vim.diagnostic.goto_prev, "跳转到上一个错误/警告")

					-- 跳转到下一个诊断信息（移动到下一个报错 Error 或警告 Warning 处）
					map("]g", vim.diagnostic.goto_next, "跳转到下一个错误/警告")

					-- 跳转到上一个严重错误 (新 API)
					map("g[", function()
						vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = true })
					end, "跳转到上一个错误")

					-- 跳转到下一个严重错误 (新 API)
					map("g]", function()
						vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = true })
					end, "跳转到下一个错误")

					-- map("gd", vim.lsp.buf.definition, "Goto Definition")
					-- map("gi", vim.lsp.buf.implementation, "Goto Implementation")
					-- map("grt", vim.lsp.buf.type_definition, "Type Definition")
					-- map("grn", vim.lsp.buf.rename, "Rename")
					-- map("gra", vim.lsp.buf.code_action, "Code Action", { "n", "x" })
					-- map("grd", vim.lsp.buf.declaration, "Goto Declaration")
					-- map("[g", vim.diagnostic.goto_prev, "Previous Diagnostic")
					-- map("]g", vim.diagnostic.goto_next, "Next Diagnostic")

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

			-- 仅安装目标语言的 LSP
			mason_lspconfig.setup({
				-- ensure_installed = { "lua_ls", "marksman", "texlab", "pyright", "basedpyright","jsonls","clangd", },
				ensure_installed = { "lua_ls", "marksman", "texlab", "basedpyright", "jsonls", "clangd" },
				automatic_installation = true,
			})

			-- Lua 语言服务专属配置
			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						workspace = { checkThirdParty = false },
					},
				},
			})

			-- 非目标语言 LSP 保持注释：
			vim.lsp.enable({ "lua_ls", "marksman", "texlab", "clangd", "jsonls", "basedpyright" })
		end,
	},

	---------------------------------------------------------------------------
	-- 3. nvim-cmp 智能补全
	---------------------------------------------------------------------------
	{
		"hrsh7th/nvim-cmp",
		-- event = "VeryLazy",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
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

			local function jump_out_pair_forward_or_tab()
				local row, col = unpack(vim.api.nvim_win_get_cursor(0))
				local line = vim.api.nvim_get_current_line()
				if line:sub(col + 1, col + 1):match("[%)%]%}'\"`]") then
					vim.api.nvim_win_set_cursor(0, { row, col + 1 })
				else
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
				end
			end

			local function jump_out_pair_backward_or_stab()
				local row, col = unpack(vim.api.nvim_win_get_cursor(0))
				local line = vim.api.nvim_get_current_line()
				if line:sub(col, col):match("[%(%[%{'\"`]") then
					vim.api.nvim_win_set_cursor(0, { row, math.max(col - 1, 0) })
				else
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<S-Tab>", true, false, true), "n", false)
				end
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
							-- 如果不在成对符号内部，安全降级回普通 Tab 输入或缩进
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
		end,
	},

	---------------------------------------------------------------------------
	-- 4. wilder.nvim
	---------------------------------------------------------------------------
	{
		"gelguy/wilder.nvim",
		event = "CmdlineEnter",
		dependencies = { { "romgrk/fzy-lua-native", build = "make" } },
		config = function()
			local wilder = safe_require("wilder")
			if not wilder then
				return
			end

			wilder.setup({ modes = { ":", "/", "?" } })
			wilder.set_option("next_key", 0)
			wilder.set_option("previous_key", 0)
			wilder.set_option("accept_key", 0)
			wilder.set_option("reject_key", 0)

			local highlighters = {}
			if type(wilder.pcre2_highlighter) == "function" then
				table.insert(highlighters, wilder.pcre2_highlighter())
			end
			table.insert(highlighters, wilder.basic_highlighter())

			local cmdline_pl = wilder.cmdline_pipeline({
				fuzzy = 1,
				fuzzy_filter = (type(wilder.lua_fzy_filter) == "function" and wilder.lua_fzy_filter())
					or wilder.vim_fuzzy_filter(),
			})
			local search_pl = wilder.search_pipeline()

			wilder.set_option(
				"pipeline",
				wilder.branch(
					{ wilder.check(function(_, x)
						return vim.fn.empty(x) == 1
					end), wilder.history(15) },
					cmdline_pl,
					search_pl
				)
			)

			local renderer = wilder.popupmenu_renderer(wilder.popupmenu_border_theme({
				highlights = { border = "Normal", accent = "WilderAccent", selected_accent = "WilderSelectedAccent" },
				highlighter = highlighters,
				left = { " ", wilder.popupmenu_devicons() },
				right = { " ", wilder.popupmenu_scrollbar() },
				max_height = 15,
				pumblend = 0,
			}))
			wilder.set_option("renderer", renderer)

			pcall(vim.api.nvim_set_hl, 0, "WilderAccent", { fg = "#00afaf" })
			pcall(vim.api.nvim_set_hl, 0, "WilderSelectedAccent", { fg = "#00afaf", bg = "#4e4e4e" })

			vim.api.nvim_set_keymap(
				"c",
				"<Tab>",
				"wilder#in_context() ? wilder#next() : '<Tab>'",
				{ noremap = true, expr = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"c",
				"<S-Tab>",
				"wilder#in_context() ? wilder#previous() : '<C-d>'",
				{ noremap = true, expr = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"c",
				"<Down>",
				"wilder#in_context() ? wilder#next() : '<Down>'",
				{ noremap = true, expr = true, silent = true }
			)
			vim.api.nvim_set_keymap(
				"c",
				"<Up>",
				"wilder#in_context() ? wilder#previous() : '<Up>'",
				{ noremap = true, expr = true, silent = true }
			)

			pcall(vim.cmd, "silent! UpdateRemotePlugins")
		end,
	},
}
