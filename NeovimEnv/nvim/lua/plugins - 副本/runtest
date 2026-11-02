---@diagnostic disable: undefined-global
return {
	{
		"Civitasv/cmake-tools.nvim",
		keys = {
			{ "<leader>cmg", "<cmd>CMakeGenerate<cr>", desc = "CMake 生成" },
			{ "<leader>cmb", "<cmd>CMakeBuild<cr>", desc = "CMake 构建" },
			{ "<leader>cmr", "<cmd>CMakeRun<cr>", desc = "CMake 运行" },
			{ "<leader>cmc", "<cmd>CMakeClean<cr>", desc = "CMake 清理" },
			{ "<leader>cmt", "<cmd>CMakeSelectBuildType<cr>", desc = "选择构建类型" },
			{ "<leader>cmp", "<cmd>CMakeSelectPreset<cr>", desc = "选择 Preset" },
			{ "<leader>cmd", "<cmd>CMakeDebug<cr>", desc = "CMake 调试" },
		},
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			local osys = require("cmake-tools.osys")
			require("cmake-tools").setup({
				cmake_command = "cmake",
				ctest_command = "ctest",
				cmake_build_type = "Debug",
				cmake_use_preset = false,
				cmake_regenerate_on_save = true,
				cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
				cmake_build_options = {},
				cmake_build_directory = function()
					if osys.iswin32 then
						return "build\\${variant:buildType}"
					end
					return "build/${variant:buildType}"
				end,
				cmake_compile_commands_options = {
					action = "copy",
					target = vim.loop.cwd(),
				},
				cmake_variants_message = {
					short = { show = true },
					long = { show = true, max_length = 40 },
				},
				cmake_dap_configuration = {
					name = "cpp",
					type = "cppdbg",
					request = "launch",
					stopOnEntry = false,
					runInTerminal = true,
					console = "integratedTerminal",
				},
				cmake_executor = {
					name = "quickfix",
					opts = {},
					default_opts = {
						quickfix = {
							show = "always",
							position = "belowright",
							size = 10,
							encoding = "utf-8",
							auto_close_when_success = true,
						},
						toggleterm = {
							direction = "float",
							close_on_exit = false,
							auto_scroll = true,
							singleton = true,
						},
						terminal = {
							name = "Main Terminal",
							prefix_name = "[CMakeTools]: ",
							split_direction = "horizontal",
							split_size = 11,
							single_terminal_per_instance = true,
							single_terminal_per_tab = true,
							keep_terminal_static_location = true,
							auto_resize = true,
							start_insert = false,
							focus = false,
							do_not_add_newline = false,
						},
					},
				},
				cmake_runner = {
					name = "terminal",
					opts = {},
					default_opts = {
						quickfix = {
							show = "always",
							position = "belowright",
							size = 10,
							encoding = "utf-8",
							auto_close_when_success = true,
						},
						toggleterm = {
							direction = "float",
							close_on_exit = false,
							auto_scroll = true,
							singleton = true,
						},
						terminal = {
							name = "Main Terminal",
							prefix_name = "[CMakeTools]: ",
							split_direction = "horizontal",
							split_size = 11,
							single_terminal_per_instance = true,
							single_terminal_per_tab = true,
							keep_terminal_static_location = true,
							auto_resize = true,
							start_insert = false,
							focus = false,
							do_not_add_newline = false,
						},
					},
				},
				cmake_notifications = {
					runner = { enabled = true },
					executor = { enabled = true },
					spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
					refresh_rate_ms = 100,
				},
				cmake_virtual_text_support = true,
				cmake_use_scratch_buffer = false,
			})
		end,
	},

	-- {
	--     "michaelb/sniprun",
	--     event = "VeryLazy",
	--     build = "sh install.sh",
	--     dependencies = { "nvim-treesitter/nvim-treesitter" }, -- 结合 treesitter
	--     config = function()
	--         require("sniprun").setup({
	--             -- display = { "TerminalWithFocus" },                        -- 运行后自动聚焦到输出终端
	--             display = { "Terminal" },                                 -- 结果以终端方式呈现
	--             selected_interpreters = { "C_original", "Cpp_original" }, -- 只启用C/C++解释器
	--             repl_enable = {},                                         -- 禁用REPL（即不启用交互式解释器，只运行代码片段）
	--             interpreter_options = {
	--                 C_original = { compiler = "gcc" },
	--                 Cpp_original = { compiler = "g++" },
	--             },
	--         })
	--
	--         -- 结合 nvim-treesitter：选中函数块或语法节点后 :SnipRun
	--         -- 例如，光标在函数上，输入 :TSNodeUnderCursor，然后 :SnipRun
	--         -- 推荐快捷键：选中代码块后运行
	--         vim.keymap.set("v", "<leader>sr", ":SnipRun<CR>", { noremap = true, silent = true, desc = "运行选中C/C++代码" })
	--         vim.keymap.set("n", "<leader>sr", ":SnipRun<CR>", { noremap = true, silent = true, desc = "运行当前行C/C++代码" })
	--         -- 操作符方式
	--         vim.keymap.set('n', '<leader>s', '<Plug>SnipRunOperator', { desc = "SnipRun 操作符" })
	--         vim.keymap.set("v", "<leader>sc", ":SnipReset<CR>", { noremap = true, silent = true, desc = "Ctrl + C" })
	--         vim.keymap.set("n", "<leader>sc", ":SnipReset<CR>", { noremap = true, silent = true, desc = "Ctrl + C" })
	--         vim.keymap.set("v", "<leader>sq", ":SnipClose<CR>", { noremap = true, silent = true, desc = "Ctrl + l" })
	--         vim.keymap.set("n", "<leader>sq", ":SnipClose<CR>", { noremap = true, silent = true, desc = "Ctrl + l" })
	--     end
	-- },
	--
	-- {
	--     "vim-test/vim-test",
	--     lazy = true, -- 只在被其它插件需要时加载
	--     config = function()
	--         -- 使用 make 作为 C 的测试 runner
	--         vim.cmd([[
	--             let test#c#neovim#executable = 'make run'
	--         ]])
	--         -- 可选：设置测试输出在 quickfix
	--         -- vim.g["test#strategy"] = "neovim"
	--     end,
	-- },
	--
	-- -- ultest 主体
	-- {
	--     "rcarriga/vim-ultest",
	--     event = "VeryLazy",
	--     dependencies = { "vim-test/vim-test", "nvim-lua/plenary.nvim" },
	--     build = ":UpdateRemotePlugins", -- 安装后需要运行一次
	--     config = function()
	--         -- 启用 ultest 浮动终端
	--         vim.g.ultest_use_pty = 1
	--         vim.g.ultest_output_on_run = 1
	--         vim.g.ultest_virtual_text = 1
	--         vim.g.ultest_pass_sign = "✔"
	--         vim.g.ultest_fail_sign = "✗"
	--         vim.g.ultest_running_sign = "➤"
	--         vim.g.ultest_not_run_sign = "?"
	--         vim.g.ultest_max_threads = 8
	--         vim.g.ultest_output_on_line = 1
	--
	--         -- 推荐 keymap
	--         vim.keymap.set("n", "<leader>tn", "<cmd>UltestNearest<CR>", { desc = "ultest: 运行光标处测试" })
	--         vim.keymap.set("n", "<leader>tf", "<cmd>Ultest<CR>", { desc = "ultest: 运行当前文件测试" })
	--         vim.keymap.set("n", "<leader>ts", "<cmd>UltestSummary<CR>", { desc = "ultest: 测试摘要面板" })
	--         vim.keymap.set("n", "<leader>to", "<cmd>UltestOutput<CR>", { desc = "ultest: 查看测试输出" })
	--         vim.keymap.set("n", "<leader>tr", "<cmd>UltestLast<CR>", { desc = "ultest: 重新运行上次测试" })
	--     end,
	-- },
}
