---@diagnostic disable: undefined-global
return {
	{
		"lervag/vimtex",
		-- lazy = false,
		ft = { tex },
		init = function()
			vim.g.vimtex_version_check = 0
		end,
		config = function()
			vim.g.tex_flavor = "latex"
			vim.g.vimtex_compiler_method = "latexmk"

			-- 禁用字符隐藏替换，完整展示 LaTeX 宏与源码
			vim.g.vimtex_syntax_conceal_disable = 1

			-- Windows 专属 XeLaTeX 单次构建配置（避免临时文件占用报错）
			vim.g.vimtex_compiler_latexmk = {
				executable = "latexmk",
				options = {
					"-xelatex",
					"-file-line-error",
					"-synctex=1",
					"-interaction=nonstopmode",
				},
				continuous = 0,
				callback = 0,
			}
			vim.g.vimtex_compiler_latexmk_clean_on_exit = 1
			vim.g.vimtex_clean_on_exit = 1

			-- 关闭保存时自动编译，避免 Windows 环境下与 SumatraPDF 频繁互锁
			vim.g.vimtex_compiler_autostart = 0
			vim.g.vimtex_compiler_start_on_save = 0

			-- Windows PDF 实时联动：SumatraPDF 反向搜索配置
			vim.g.vimtex_view_method = "general"
			vim.g.vimtex_view_general_viewer = "SumatraPDF"
			vim.g.vimtex_view_general_options = "-reuse-instance -forward-search @tex @line @pdf"

			-- 过滤无实质危害的警告信息，保持输出窗口整洁
			vim.g.vimtex_quickfix_ignore_filters = {
				"Underfull",
				"Overfull",
				"specifier changed to",
				"Token not allowed in a PDF string",
				"LaTeX Warning: Float too large for page",
				"contains only floats",
				"^LaTeX Warning:",
				"^Warning:",
				"^Package .* Warning:",
				"Reference .* undefined",
				"Citation .* undefined",
			}
			vim.g.vimtex_quickfix_open_on_warning = 0

			-- 侧边大纲目录（TOC）配置
			vim.g.vimtex_toc_config = {
				name = "TOC",
				layers = { "content", "todo", "include" },
				split_width = 25,
				todo_sorted = 0,
				show_help = 1,
				show_numbers = 1,
			}

			-- tex 缓冲区专属事件与按键映射
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "tex",
				desc = "LaTeX 专属配置与快捷键",
				callback = function()
					-- ★ 关键修正：仅在 tex 缓冲区局部关闭 conceal，绝不污染 Markdown 与 Obsidian
					vim.opt_local.conceallevel = 0

					local opts = { buffer = 0, noremap = true, silent = true }
					vim.keymap.set("n", "<space>lv", "<plug>(vimtex-view)", opts)
					vim.keymap.set("n", "<space>ll", "<plug>(vimtex-compile)", opts)
					vim.keymap.set("n", "<space>le", "<plug>(vimtex-errors)", opts)
					vim.keymap.set("n", "<space>lc", "<plug>(vimtex-clean)", opts)
					vim.keymap.set("n", "<space>lt", "<plug>(vimtex-toc-open)", opts)
					vim.keymap.set("n", "<space>li", "<plug>(vimtex-info)", opts)
					vim.keymap.set("n", "<space>lf", function()
						require("conform").format({
							bufnr = 0,
							lsp_fallback = true,
							timeout_ms = 2000,
						})
					end, { buffer = 0, desc = "[VimTeX] 格式化文档" })
				end,
			})
		end,
	},
}

