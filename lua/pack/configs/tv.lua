-- === television模糊查找 ===
if vim.g.vscode then return end

local P = {
	name = "tv.nvim", -- 仓库名
}

local function load_plugin()
	PackUtils.load(P, function()
		local h = require("tv").handlers
		require("tv").setup({
			channels = {
				["git-files"] = {
					handlers = {
						["<CR>"] = h.open_as_files,
					},
				},
				files = {
					handlers = {
						["<CR>"] = h.open_as_files, -- default: open selected files
					},
				},
				-- `text`: ripgrep search through file contents
				text = {
					handlers = {
						['<CR>'] = h.open_at_line, -- Jump to line:col in file
					},
				},
			},
		})
	end)
	-- 提前触发 BufReadPost 的事件钩子，让 LSP 悄悄在后台 require 完毕
	vim.schedule(function()
		vim.api.nvim_exec_autocmds("BufReadPost", { modeline = false })
	end)
end

vim.keymap.set({ "n", "v" }, "<c-t>", function()
	load_plugin()
	if vim.fs.root(0, '.git') then
		vim.cmd('Tv git-files')
	else
		vim.cmd('Tv files')
	end
end, { desc = "Smart Tv: git-files or files" })

vim.keymap.set({ "n", "v" }, "<c-f>", function()
	load_plugin()
	vim.cmd('Tv text')
end, { desc = "模糊查找字符串" })
