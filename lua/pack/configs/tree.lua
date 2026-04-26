-- === nvim-tree ===
if vim.g.vscode then return end

local P = {
	name = "nvim-tree.lua",
	deps = { "nvim-web-devicons" }, -- 依赖图标库
}

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- 快捷键触发懒加载
vim.keymap.set("n", "<leader>e", function()
	PackUtils.load(P, function()
		require("nvim-tree").setup({
			sync_root_with_cwd = false, -- 随目录变化自动更新
			update_focused_file = {
				enable = false,
				update_root = true,
			},
			view = {
				width = 30,
				relativenumber = true,
				side = "left",
			},
			renderer = {
				root_folder_label = false, -- 隐藏根目录名称，更简洁
			},
			actions = {
				open_file = {
					quit_on_open = false, -- 打开文件后关闭文件树
				},
			},
		})
	end)
	vim.cmd("NvimTreeToggle")
end, { desc = "Toggle File Tree" })

-- 可选：添加一些常用内部操作键位
vim.api.nvim_create_autocmd("FileType", {
	pattern = "nvimtree",
	callback = function()
		vim.keymap.set("n", "<CR>", "nvim-tree:open", { buffer = true })
		vim.keymap.set("n", "h", "nvim-tree:node-up", { buffer = true })
		vim.keymap.set("n", "l", "nvim-tree:node-down", { buffer = true })
	end,
})

