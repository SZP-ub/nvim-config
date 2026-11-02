-- 监听 GUI 挂载完成事件，再执行关闭 GUI 命令行的指令
vim.api.nvim_create_autocmd("UIEnter", {
	callback = function()
		if vim.fn.exists(":GuiCmdline") == 2 then
			vim.cmd("GuiCmdline 0")
		end
		if vim.fn.exists(":GuiPopupmenu") == 2 then
			vim.cmd("GuiPopupmenu 0")
		end
	end,
})
