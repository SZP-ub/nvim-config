---@diagnostic disable: undefined-global
return {

	-- 书签插件
	-- {
	-- 	"chentoast/marks.nvim",
	-- 	event = "VeryLazy",
	-- 	keys = {
	-- 		{ "m", mode = "n", desc = "Marks: trigger (set/jump 标记时触发加载)" },
	-- 		{ "dm", mode = "n", desc = "Marks: 删除标记（dm{char} 交互式）" },
	-- 		{ "'", mode = "n", desc = "Marks: jump to mark (built-in) - trigger load" },
	-- 		{ "`", mode = "n", desc = "Marks: jump to mark (built-in) - trigger load" },
	-- 		{ "]`", mode = "n", desc = "Marks: next mark" },
	-- 		{ "[`", mode = "n", desc = "Marks: prev mark" },
	-- 	},
	-- 	config = function()
	-- 		local ok, marks = pcall(require, "marks")
	-- 		if not ok then
	-- 			vim.notify("marks.nvim not found", vim.log.levels.WARN)
	-- 			return
	-- 		end
	--
	-- 		marks.setup({
	-- 			default_mappings = false,
	-- 			force_write_shada = false,
	-- 		})
	--
	-- 		local map = vim.keymap.set
	-- 		local notify = vim.notify
	--
	-- 		-- dm: 交互式删除：按 dm 后接字母（如 dmx 删除 mark x）
	-- 		map("n", "dm", function()
	-- 			-- 读取下一个按键（阻塞直到输入）
	-- 			local okc, c = pcall(vim.fn.getchar)
	-- 			if not okc or not c then
	-- 				return
	-- 			end
	-- 			local ch = vim.fn.nr2char(c)
	--
	-- 			-- 只接受字母作为命名标记（a-z/A-Z）
	-- 			if not ch:match("%a") then
	-- 				notify("Invalid mark: " .. tostring(ch), vim.log.levels.WARN)
	-- 				return
	-- 			end
	--
	-- 			-- 优先使用 marks.nvim 的内部 API 删除指定标记
	-- 			local deleted = false
	-- 			if marks.mark_state and type(marks.mark_state.delete_mark) == "function" then
	-- 				local ok_del, err = pcall(marks.mark_state.delete_mark, marks.mark_state, ch)
	-- 				if not ok_del then
	-- 					notify("marks.mark_state.delete_mark error: " .. tostring(err), vim.log.levels.WARN)
	-- 				else
	-- 					deleted = true
	-- 				end
	-- 			end
	--
	-- 			-- 作为保险，调用内置 delmarks 命令（确保 Neovim 层面的标记也被移除）
	-- 			local ok_cmd, cmd_err = pcall(vim.cmd, "delmarks " .. ch)
	-- 			if not ok_cmd then
	-- 				notify("delmarks failed: " .. tostring(cmd_err), vim.log.levels.WARN)
	-- 			end
	--
	-- 			-- 刷新显示（如果模块提供 refresh）
	-- 			if type(marks.refresh) == "function" then
	-- 				pcall(marks.refresh, true)
	-- 			end
	--
	-- 			notify(
	-- 				string.format("Deleted mark '%s' (api=%s, delmarks=%s)", ch, tostring(deleted), tostring(ok_cmd)),
	-- 				vim.log.levels.INFO
	-- 			)
	-- 		end, { desc = "Marks: delete mark interactively (dm{char})" })
	--
	-- 		-- 下一个 / 上一个 标记映射（调用 marks 模块的方法或回退）
	-- 		map("n", "]`", function()
	-- 			if type(marks.next) == "function" then
	-- 				pcall(marks.next)
	-- 			else
	-- 				pcall(vim.cmd, "normal! m]")
	-- 			end
	-- 		end, { desc = "Marks: next mark" })
	--
	-- 		map("n", "[`", function()
	-- 			if type(marks.prev) == "function" then
	-- 				pcall(marks.prev)
	-- 			else
	-- 				pcall(vim.cmd, "normal! m[")
	-- 			end
	-- 		end, { desc = "Marks: previous mark" })
	--
	-- 		-- 可选：preview 映射（若可用）
	-- 		if type(marks.preview) == "function" then
	-- 			map("n", "m:", function()
	-- 				pcall(marks.preview)
	-- 			end, { desc = "Marks: preview mark" })
	-- 		end
	-- 	end,
	-- },

	{
		"kshenoy/vim-signature",
		event = "VeryLazy",
		keys = {
			{ "m", mode = "n", desc = "添加/跳转标记" },
			{ "dm", mode = "n", desc = "删除标记" },
			{ "'", mode = "n", desc = "跳转到标记" },
			{ "`", mode = "n", desc = "跳转到标记" },
			{ "]`", mode = "n", desc = "下一个标记" },
			{ "[`", mode = "n", desc = "上一个标记" },
		},
	},

	-- 文件树侧边栏
	{
		"nvim-tree/nvim-tree.lua",
		-- cmd = "NvimTreeToggle", -- 只在打开文件树时加载
		keys = {
			{ "<C-n>", "<cmd>NvimTreeToggle<CR>", desc = "切换NvimTree" },
		},
		config = function()
			require("nvim-tree").setup({
				sort_by = "case_sensitive",
				view = { width = 40 },
				renderer = { group_empty = true },
				filters = { dotfiles = true },
			})
			open_files_do_not_replace_types = {
				"terminal",
			}
		end,
	},

	-- 代码结构标签栏
	{
		"preservim/tagbar",
		-- cmd = "TagbarToggle",
		keys = {
			{
				"<leader>o",
				"<cmd>TagbarToggle<CR>",
				desc = "切换 Tagbar 代码结构窗口",
			},
		},
		config = function()
			vim.g.tagbar_autofocus = 1
			vim.g.tagbar_width = 30
			vim.g.tagbar_sort = 0
		end,
	},

	-- {
	-- 	"kevinhwang91/nvim-ufo",
	-- 	event = "VeryLazy",
	-- 	dependencies = {
	-- 		{ "kevinhwang91/promise-async", event = "VeryLazy" },
	-- 		{ "nvim-treesitter/nvim-treesitter", lazy = true },
	-- 	},
	-- 	config = function()
	-- 		-- 安全加载 ufo，避免 require 失败时整个配置报错
	-- 		local ok, ufo = pcall(require, "ufo")
	-- 		if not ok then
	-- 			vim.notify("nvim-ufo not found", vim.log.levels.WARN)
	-- 			return
	-- 		end
	--
	-- 		-- 为 ufo 推荐的折叠相关选项设置（主要是展示与行为调整）
	-- 		vim.o.foldcolumn = "0" -- 显示折叠列（用于查看折叠层级）
	-- 		vim.o.foldlevel = 99 -- 设置一个较大的 foldlevel，默认打开大部分折叠
	-- 		vim.o.foldlevelstart = 99 -- 缓冲区打开时的初始 foldlevel
	-- 		vim.o.foldenable = true -- 启用折叠
	-- 		vim.o.foldmethod = "manual" -- 由 ufo 提供折叠信息，使用 manual 避免 vim 自身重写
	--
	-- 		-- 尝试向 lspconfig 的默认配置添加 foldingRange 能力，这样通过 lspconfig 启动的服务器会收到该能力
	-- 		local capabilities = vim.lsp.protocol.make_client_capabilities()
	-- 		capabilities.textDocument.foldingRange = {
	-- 			dynamicRegistration = false,
	-- 			lineFoldingOnly = true, -- 仅按行折叠，避免字符级折叠带来的复杂性
	-- 		}
	--
	-- 		local ok_lsp, lspconfig = pcall(require, "lspconfig")
	-- 		-- 如果能获取到 lspconfig 且其 util.default_config 存在，则合并 foldingRange 能力到默认能力中
	-- 		if ok_lsp and lspconfig and lspconfig.util and lspconfig.util.default_config then
	-- 			lspconfig.util.default_config.capabilities =
	-- 				vim.tbl_deep_extend("force", lspconfig.util.default_config.capabilities or {}, capabilities)
	-- 		end
	--
	-- 		-- fold 虚拟文本处理器（基于 ufo 示例，并增加健壮性处理）
	-- 		-- 这个 handler 用来在折叠行显示像 " 󰁂 N " 这样的后缀，表示折叠范围的行数
	-- 		local handler = function(virtText, lnum, endLnum, width, truncate)
	-- 			local newVirtText = {}
	-- 			-- 后缀，显示折叠的行数（endLnum - lnum）
	-- 			local suffix = (" 󰁂 %d "):format(endLnum - lnum + 1)
	-- 			local sufWidth = vim.fn.strdisplaywidth(suffix)
	-- 			-- 目标宽度是整行宽度减去后缀宽度
	-- 			local targetWidth = width - sufWidth
	-- 			local curWidth = 0
	-- 			for _, chunk in ipairs(virtText) do
	-- 				local chunkText = chunk[1]
	-- 				local hlGroup = chunk[2]
	-- 				local chunkWidth = vim.fn.strdisplaywidth(chunkText)
	-- 				if curWidth + chunkWidth <= targetWidth then
	-- 					-- 如果当前块可以完全放下，直接插入
	-- 					table.insert(newVirtText, { chunkText, hlGroup })
	-- 					curWidth = curWidth + chunkWidth
	-- 				else
	-- 					-- 否则截断当前块以适应剩余空间
	-- 					chunkText = truncate(chunkText, targetWidth - curWidth)
	-- 					table.insert(newVirtText, { chunkText, hlGroup })
	-- 					chunkWidth = vim.fn.strdisplaywidth(chunkText)
	-- 					-- 如果截断后仍有剩余宽度，用空格填充以保持对齐
	-- 					if curWidth + chunkWidth < targetWidth then
	-- 						suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
	-- 					end
	-- 					break
	-- 				end
	-- 			end
	-- 			-- 在行尾加入后缀，并使用 MoreMsg 高亮组
	-- 			table.insert(newVirtText, { suffix, "MoreMsg" })
	-- 			return newVirtText
	-- 		end
	--
	-- 		-- 一个简单的 ftMap + provider_selector 示例（按文件类型选择折叠提供者）
	-- 		-- 可以按需扩展：例如指定某些文件使用 treesitter 或 indent，或禁用某些文件类型
	-- 		local ftMap = {
	-- 			vim = "indent", -- vim 文件使用 indent 提供者
	-- 			python = { "indent" }, -- python 仅使用 indent（示例，实际可加 treesitter）
	-- 			git = "", -- git 文件不使用任何 provider（禁用）
	-- 		}
	--
	-- 		-- ufo 的主配置
	-- 		ufo.setup({
	-- 			-- provider_selector 决定当前缓冲区使用哪个折叠提供者
	-- 			provider_selector = function(bufnr, filetype, buftype)
	-- 				-- 优先使用 ftMap 中的配置，否则回退到 treesitter + indent 的组合
	-- 				return ftMap[filetype] or { "treesitter", "indent" }
	-- 			end,
	-- 			fold_virt_text_handler = handler, -- 使用上面定义的虚拟文本 handler
	-- 			open_fold_hl_timeout = 150, -- 展开折叠时高亮超时时间（毫秒）
	-- 			-- 针对不同文件类型关闭某些折叠 kind 的示例配置
	-- 			close_fold_kinds_for_ft = {
	-- 				-- default = { "imports", "comment" }, -- 默认关闭 imports/comment 类型的折叠
	-- 				json = { "array" }, -- json 默认关闭 array 类型折叠
	-- 				c = { "comment", "region" }, -- c 文件关闭 comment 和 region
	-- 				-- c = { "region" }, -- c 文件关闭 comment 和 region
	-- 			},
	-- 			-- 针对不同文件类型是否允许关闭当前行的折叠
	-- 			close_fold_current_line_for_ft = {
	-- 				default = true,
	-- 				c = false,
	-- 			},
	-- 			-- 折叠预览窗口相关配置
	-- 			preview = {
	-- 				win_config = {
	-- 					-- 与 LSP hover 一致的边框样式
	-- 					border = "shadow",
	-- 					-- 与 LSP hover 保持相同的高亮映射（NormalFloat / FloatBorder）
	-- 					-- 你也可以用 "Normal:Folded" 之类的自定义值，但要和 hover 保持一致
	-- 					winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
	-- 					-- 透明度（与 hover 通常为 0）
	-- 					winblend = 0,
	-- 					-- 可选：限定最大宽高（根据需要调整）
	-- 					maxwidth = 80,
	-- 					maxheight = 20,
	-- 				},
	-- 				mappings = {
	-- 					scrollU = "<C-u>",
	-- 					scrollD = "<C-d>",
	-- 					jumpTop = "[",
	-- 					jumpBot = "]",
	-- 				},
	-- 			},
	-- 		})
	--
	-- 		-- Keymaps（使用 pcall / 安全包装，避免函数不存在时报错）
	-- 		-- vim.keymap.set("n", "zR", function()
	-- 		-- 	-- 全部展开折叠
	-- 		-- 	if ufo and ufo.openAllFolds then
	-- 		-- 		pcall(ufo.openAllFolds)
	-- 		-- 	end
	-- 		-- end, { desc = "UFO: open all folds" })
	--
	-- 		-- vim.keymap.set("n", "zM", function()
	-- 		-- 	-- 全部关闭折叠
	-- 		-- 	if ufo and ufo.closeAllFolds then
	-- 		-- 		pcall(ufo.closeAllFolds)
	-- 		-- 	end
	-- 		-- end, { desc = "UFO: close all folds" })
	--
	-- 		-- vim.keymap.set("n", "zr", function()
	-- 		-- 	-- 打开除指定 kinds 之外的折叠（按配置器决定行为）
	-- 		-- 	if ufo and ufo.openFoldsExceptKinds then
	-- 		-- 		pcall(ufo.openFoldsExceptKinds)
	-- 		-- 	end
	-- 		-- end, { desc = "UFO: open folds except kinds" })
	--
	-- 		-- vim.keymap.set("n", "zm", function()
	-- 		-- 	-- 关闭满足条件的折叠（例如按 kinds 关闭）
	-- 		-- 	if ufo and ufo.closeFoldsWith then
	-- 		-- 		pcall(ufo.closeFoldsWith)
	-- 		-- 	end
	-- 		-- end, { desc = "UFO: close folds with" })
	-- 	end,
	-- },
}
