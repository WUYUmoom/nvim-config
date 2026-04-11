-- === television模糊查找 ===
if vim.g.vscode then return end

local P = {
	name = "tv.nvim", -- 仓库名
	module = "tv",   -- require模块名
}

local function load_plugin()
	PackUtils.load(P, function(plugin)
		local h = plugin.handlers
		plugin.setup({
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
