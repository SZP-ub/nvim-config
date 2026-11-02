---@diagnostic disable: undefined-global
local uv = vim.uv or vim.loop

return {

	-- 自动保存：切出窗口/离开 buffer 时自动保存
	{
		"okuuva/auto-save.nvim",
		event = "VeryLazy",
		config = function()
			require("auto-save").setup({
				trigger_events = {
					immediate_save = { "BufLeave", "WinLeave", "ModeChanged" },
					defer_save = {},
					cancel_deferred_save = {},
				},
				condition = function(buf)
					-- 仅在文件被修改且为常规可编辑 buffer 时触发自动保存
					return vim.bo[buf].modified and vim.bo[buf].buftype == ""
				end,
				debounce_delay = 0,
			})
		end,
	},

	-- 多窗口数字快捷跳转（<leader>1 ~ <leader>9）
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
		config = false,
	},

	-- 会话管理（mini.sessions）
	{
		"echasnovski/mini.sessions",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>so", mode = "n", desc = "加载会话" },
			{ "<leader>ss", mode = "n", desc = "保存当前会话" },
			{ "<leader>sd", mode = "n", desc = "删除会话" },
		},
		config = function()
			local Path = require("plenary.path")
			local MiniSessions = require("mini.sessions")

			local session_dir = Path:new(vim.fn.stdpath("data"), "sessions").filename
			vim.fn.mkdir(session_dir, "p")

			MiniSessions.setup({
				directory = session_dir,
				file = "",
				autoread = true,
				autowrite = false,
				force = { read = false, write = false, delete = false },
				verbose = { read = false, write = false, delete = false },
				hooks = nil,
			})

			local function sanitize_name(name)
				name = name:match("([^/\\]+)$") or name
				name = name:gsub("[^%w%._%-]", "_")
				return name == "" and "no_name" or name
			end

			local function save_session_by_buf_overwrite()
				local bufname = vim.api.nvim_buf_get_name(0) or ""
				local short = bufname == "" and ("buf" .. tostring(vim.api.nvim_get_current_buf()))
					or vim.fn.fnamemodify(bufname, ":t")
				short = sanitize_name(short)

				local fname = session_dir .. "/" .. short

				if vim.fn.filereadable(fname) == 1 then
					local ok_rm, err_rm = pcall(function()
						os.remove(fname)
					end)
					if not ok_rm then
						local ts = os.date("%Y%m%d%H%M%S")
						fname = session_dir .. "/" .. short .. "_" .. ts
						vim.notify(
							"无法删除旧会话文件，改为备份存储: "
								.. fname
								.. " ("
								.. tostring(err_rm)
								.. ")",
							vim.log.levels.WARN
						)
					end
				end

				local ok_write, err_write = pcall(function()
					vim.cmd("mksession! " .. vim.fn.fnameescape(fname))
				end)
				if not ok_write then
					vim.notify("保存会话失败: " .. tostring(err_write), vim.log.levels.ERROR)
					return
				end
				vim.notify("会话已保存为: " .. fname, vim.log.levels.INFO)
			end

			vim.keymap.set("n", "<leader>so", function()
				MiniSessions.select()
			end, { desc = "加载会话（选择器）" })

			vim.keymap.set("n", "<leader>ss", function()
				local ok, err = pcall(save_session_by_buf_overwrite)
				if not ok then
					vim.notify("保存会话错误: " .. tostring(err), vim.log.levels.ERROR)
				end
			end, { desc = "按当前 buffer 名称保存会话" })

			vim.keymap.set("n", "<leader>sd", function()
				local stat = uv.fs_stat(session_dir)
				if not stat then
					vim.notify("会话目录不存在: " .. session_dir, vim.log.levels.WARN)
					return
				end

				local files = vim.fn.readdir(session_dir)
				if not files or vim.tbl_isempty(files) then
					vim.notify("暂无可删除的会话文件", vim.log.levels.INFO)
					return
				end

				vim.ui.select(files, { prompt = "选择要删除的会话: " }, function(choice)
					if not choice or choice == "" then
						return
					end
					local ok, derr = pcall(MiniSessions.delete, choice, { force = true })
					if ok then
						vim.notify("已删除会话: " .. choice, vim.log.levels.INFO)
					else
						vim.notify("删除会话失败: " .. tostring(derr), vim.log.levels.ERROR)
					end
				end)
			end, { desc = "删除会话（选择器）" })

			-- 启动时清理 7 天前未使用的旧会话
			local expire_days = 7
			local function clean_old_sessions()
				local stat_dir = uv.fs_stat(session_dir)
				if not stat_dir then
					return
				end

				local handle = uv.fs_scandir(session_dir)
				if not handle then
					return
				end

				local now = os.time()
				while true do
					local name, typ = uv.fs_scandir_next(handle)
					if not name then
						break
					end
					if typ == "file" then
						local full = session_dir .. "/" .. name
						local st = uv.fs_stat(full)
						if st and st.mtime and st.mtime.sec then
							local diff_days = (now - st.mtime.sec) / (60 * 60 * 24)
							if diff_days > expire_days then
								pcall(os.remove, full)
							end
						end
					end
				end
			end

			clean_old_sessions()
		end,
	},
}

