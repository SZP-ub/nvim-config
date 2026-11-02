---@diagnostic disable: undefined-global
return {

	{
		"okuuva/auto-save.nvim",
		event = "VeryLazy",
		-- event = { "BufLeave", "WinLeave", "ModeChanged" }, -- 懒加载
		config = function()
			require("auto-save").setup({
				trigger_events = {
					immediate_save = { "BufLeave", "WinLeave", "ModeChanged" },
					defer_save = {}, -- 不用延迟保存事件
					cancel_deferred_save = {}, -- 不用取消延迟事件
				},
				condition = function(buf)
					return vim.bo[buf].modified and vim.bo[buf].buftype == ""
				end,
				debounce_delay = 0,
			})
		end,
	},

	-- <leader>1~9 跳转到第N个窗口
	{
		"s1n7ax/nvim-window-picker",
		keys = (function()
			local keys = {}
			for i = 1, 9 do
				table.insert(keys, {
					"<leader>" .. i,
					function()
						local wins = vim.api.nvim_tabpage_list_wins(0)
						if wins[i] then
							vim.api.nvim_set_current_win(wins[i])
							vim.cmd("normal! zz")
						end
					end,
					desc = "跳转到窗口 " .. i,
				})
			end
			return keys
		end)(),
		config = false, -- 只用快捷键，不需要额外配置
	},

	-- 会话管理

	{
		"echasnovski/mini.sessions",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>so", mode = "n", desc = "加载会话" }, -- open picker / load
			{ "<leader>ss", mode = "n", desc = "保存当前会话" }, -- write current
			{ "<leader>sd", mode = "n", desc = "删除会话" }, -- pick and delete
		},
		config = function()
			local Path = require("plenary.path")
			local MiniSessions = require("mini.sessions")

			-- 统一会话目录：stdpath('data')/sessions
			local session_dir = Path:new(vim.fn.stdpath("data"), "sessions").filename
			-- 确保目录存在
			vim.fn.mkdir(session_dir, "p")

			MiniSessions.setup({
				directory = session_dir,
				file = "", -- 本地会话文件名（保留以实现类似 CurrentDir 自动加载）
				autoread = true, -- 如果你需要自动根据当前目录加载本地会话，可开启
				autowrite = false, -- 不自动保存（与原 autosave_last_session = false 行为一致）
				force = { read = false, write = false, delete = false },
				verbose = { read = false, write = false, delete = false },
				hooks = nil, -- 可按需加入钩子（例如写入前过滤 filetype）
			})

			-- ====== 按 buffer 名称保存会话的辅助函数 ======
			local function sanitize_name(name)
				-- 取 basename（避免带路径）
				name = name:match("([^/\\]+)$") or name
				-- 把非字母数字 . - _ 的字符替换为下划线
				name = name:gsub("[^%w%._%-]", "_")
				-- 避免空名
				if name == "" then
					name = "no_name"
				end
				return name
			end

			-- 保存会话：按 buffer 名称写入，会在存在同名时尝试删除旧文件（删除失败则追加时间戳）
			local function save_session_by_buf_overwrite()
				-- 获取当前 buffer 的文件名（短名）
				local bufname = vim.api.nvim_buf_get_name(0) or ""
				local short
				if bufname == "" then
					short = "buf" .. tostring(vim.api.nvim_get_current_buf())
				else
					short = vim.fn.fnamemodify(bufname, ":t")
				end
				short = sanitize_name(short)

				-- 目标文件名（不使用扩展名）
				local fname = session_dir .. "/" .. short

				-- 如果文件已存在，先尝试删除旧文件以实现覆盖
				if vim.fn.filereadable(fname) == 1 then
					local ok_rm, err_rm = pcall(function()
						os.remove(fname)
					end)
					if not ok_rm then
						-- 无法删除旧文件：退而求其次使用时间戳以避免覆盖失败
						local ts = os.date("%Y%m%d%H%M%S")
						fname = session_dir .. "/" .. short .. "_" .. ts
						vim.notify(
							"无法删除旧会话文件，改为保存为备份文件: "
								.. fname
								.. " ("
								.. tostring(err_rm)
								.. ")",
							vim.log.levels.WARN
						)
					else
						-- 删除成功：继续使用原 fname（覆盖行为）
						vim.notify("已删除旧会话，准备覆盖保存: " .. fname, vim.log.levels.DEBUG)
					end
				end

				-- 使用 mksession! 写入会话文件（Vim 内建命令）
				local ok_write, err_write = pcall(function()
					vim.cmd("mksession! " .. vim.fn.fnameescape(fname))
				end)
				if not ok_write then
					vim.notify("保存会话失败: " .. tostring(err_write), vim.log.levels.ERROR)
					return
				end
				vim.notify("会话已保存为: " .. fname, vim.log.levels.INFO)
			end

			-- ========= 快捷键实现（与原绑定行为一致） =========
			vim.keymap.set("n", "<leader>so", function()
				MiniSessions.select()
			end, { desc = "加载会话（选择器）" })

			vim.keymap.set("n", "<leader>ss", function()
				local ok, err = pcall(save_session_by_buf_overwrite)
				if not ok then
					vim.notify("保存会话时出现错误: " .. tostring(err), vim.log.levels.ERROR)
				end
			end, { desc = "按 buffer 名称保存当前会话（覆盖同名）" })

			vim.keymap.set("n", "<leader>sd", function()
				-- 这里改用 vim.ui.select 列出 session_dir 下的文件并选择删除
				-- 以绕过 mini.sessions.select 中对 opts.action 的校验问题
				local stat = vim.loop.fs_stat(session_dir)
				if not stat then
					vim.notify("会话目录不存在或无法访问: " .. session_dir, vim.log.levels.WARN)
					return
				end

				-- 读取目录下文件名（不递归）
				local files = vim.fn.readdir(session_dir)
				if not files or vim.tbl_isempty(files) then
					vim.notify("会话目录中没有会话可删除: " .. session_dir, vim.log.levels.INFO)
					return
				end

				-- 使用 vim.ui.select 弹出选择器，让用户选择要删除的会话
				vim.ui.select(files, { prompt = "选择要删除的会话: " }, function(choice)
					if not choice or choice == "" then
						-- 用户取消或未选择
						return
					end
					-- 选中后调用 MiniSessions.delete（包裹 pcall 以捕获错误）
					-- 传入 opts.force = true 以允许删除当前会话（避免之前报错）
					local ok, derr = pcall(MiniSessions.delete, choice, { force = true })
					if ok then
						vim.notify("已删除会话: " .. choice, vim.log.levels.INFO)
					else
						vim.notify("删除会话失败: " .. tostring(derr), vim.log.levels.ERROR)
					end
				end)
			end, { desc = "删除会话（选择器）" })

			-- ========= 启动时清理过期会话（与你原来逻辑等价） =========
			local expire_days = 7
			local function clean_old_sessions()
				-- 确保目录存在
				local stat_dir = vim.loop.fs_stat(session_dir)
				if not stat_dir then
					return
				end

				-- 列出目录下的文件（不递归）
				local handle = vim.loop.fs_scandir(session_dir)
				if not handle then
					return
				end

				local now = os.time()
				while true do
					local name, typ = vim.loop.fs_scandir_next(handle)
					if not name then
						break
					end
					if typ == "file" then
						local full = session_dir .. "/" .. name
						local st = vim.loop.fs_stat(full)
						if st and st.mtime and st.mtime.sec then
							local diff_days = (now - st.mtime.sec) / (60 * 60 * 24)
							if diff_days > expire_days then
								-- 尝试删除，忽略错误
								local ok, err = pcall(function()
									os.remove(full)
								end)
								if not ok then
									-- 非致命，记录到消息
									vim.schedule(function()
										vim.notify(
											"清理旧会话失败: " .. tostring(full) .. " -> " .. tostring(err),
											vim.log.levels.WARN
										)
									end)
								end
							end
						end
					end
				end
			end

			-- 立即执行一次清理（启动时）
			clean_old_sessions()
		end,
	},
}
