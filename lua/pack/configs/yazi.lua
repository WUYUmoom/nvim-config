-- VSCode 拦截
if vim.g.vscode then
	local vscode = require("vscode")
	vim.keymap.set("n", "tt", function()
		vscode.action("yazi-vscode.toggle")
	end, { noremap = true, silent = true, desc = "Toggle Yazi (VSCode)" })
	return
end

vim.g.loaded_netrwPlugin = 1

local P = {
	name = "yazi.nvim",
	module = "yazi",
	deps = { "plenary.nvim" },
}

-- 快捷键触发懒加载
vim.keymap.set({ "n", "v" }, "tt", function()
	-- 核心：直接调用引擎，把配置逻辑传进去
	PackUtils.load(P, function(plugin)
		plugin.setup({
			open_for_directories = false,
			keymaps = { show_help = "<f1>" },
		})
	end)
	-- 提前触发 BufReadPost 的事件钩子，让 LSP 悄悄在后台 require 完毕
	vim.schedule(function()
		vim.api.nvim_exec_autocmds("BufReadPost", { modeline = false })
	end)
	vim.cmd("Yazi")
end, { desc = "Open yazi" })
