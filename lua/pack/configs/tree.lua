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
				highlight_diagnostics = "icon", -- 高亮诊断图标
				icons = {
					show = {
						file = true,
						folder = true,
						folder_arrow = true,
						git = false,     -- 禁用 Git 状态图标
						diagnostics = true, -- 启用诊断图标显示
						modified = false, -- 禁用文件修改标记
					},
					diagnostics_placement = "before", -- 诊断图标位置改为 after（文件名后面）
				},
			},
			diagnostics = {
				enable = true,
				icons = {
					error = "✘",
					warning = "▲",
					info = "ℹ",
					hint = "⚑",
				},
			},
			actions = {
				open_file = {
					quit_on_open = false, -- 打开文件后关闭文件树
				},
			},
			git = {
				enable = false, -- 完全禁用 Git 集成功能
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
