-- === 快捷键翻译 ===
local P = {
	name = "translate.nvim",
}

vim.keymap.set('n', 'tr', "viw:Translate ZH -output=replace<CR>", { noremap = true, silent = true })
vim.keymap.set('x', 'tr', ":'<,'>Translate ZH -output=replace<CR>", { noremap = true, silent = true })
vim.keymap.set('n', 'te', "viw:Translate EN -output=replace<CR>", { noremap = true, silent = true })
vim.keymap.set('x', 'te', ":'<,'>Translate EN -output=replace<CR>", { noremap = true, silent = true })
vim.keymap.set('n', 'ts', "viw:Translate ZH<CR>", { noremap = true, silent = true })
vim.keymap.set('x', 'ts', ":'<,'>Translate ZH<CR>",
	{ noremap = true, silent = true })
-- 懒加载触发器，特定命令触发
vim.api.nvim_create_user_command("Translate", function()
	PackUtils.load(P, function()
		require("translate").setup({
			default = {
				command = "translate_shell",
			},
			-- preset = {
			-- 	command = {
			-- 		translate_shell = {
			-- 			args = { "-e", "bing" }
			-- 		}
			-- 	}
			-- }
		})
	end)
end, { desc = "描述" })
