-- === Snacks ===
if vim.g.vscode then return end

local P = {
	name = "snacks.nvim",
}

local map = require("core.keymap")
map:lua("<c-g>", "Snacks.lazygit()")
map:lua("gr", "Snacks.picker.lsp_references()")

-- 修正：直接使用 Neovim 内置的 LSP 重命名功能，绕过 Snacks 的 API 问题
map:lua("<leader>rn", "vim.lsp.buf.rename()")
PackUtils.load(P, function()
	require("snacks").setup({
		image = {},
		lazygit = {
			theme = {}, 
		},
		notifier = {}, 
		picker = {
			win = {
				input = {
					keys = { 
						["<Esc>"] = { "close", mode = { "n", "i" } },
						["<c-e>"] = { "list_down", mode = { "i", "n" } },
						["<c-u>"] = { "list_up", mode = { "i", "n" } },
					}
				}
			}
		},
		-- 新增：显式启用 rename 模块
		rename = {},
	})
end)

local map = require("core.keymap")
map:lua("<c-g>", "Snacks.lazygit()")
map:lua("gr", "Snacks.picker.lsp_references()")

-- 彻底清除 Neovim 0.10+ 自带的 LSP 默认映射，解除 `gr` 的 1秒等待延迟
local default_lsp_keys = { "grr", "grn", "gra", "gri", "grt", "grx" }
for _, key in ipairs(default_lsp_keys) do
	pcall(vim.keymap.del, "n", key) -- 使用 pcall 忽略找不到映射时的报错
	pcall(vim.keymap.del, "x", key)
end
