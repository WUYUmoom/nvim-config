-- === Snacks ===
if vim.g.vscode then return end

local P = {
	name = "snacks.nvim",
}

PackUtils.load(P, function()
	require("snacks").setup({
		image = {},
		lazygit = {
			theme = {}, -- 【修改】设置为空表，阻止插件生成默认主题文件
		},
		notifier = {}, -- 替代了folke/noice.nvim插件的rcarriga/nvim-notify依赖
		picker = {
			win = {
				input = {
					keys = { -- Esc直接关闭窗口，不进入normal模式
						["<Esc>"] = { "close", mode = { "n", "i" } },
						["<c-e>"] = { "list_down", mode = { "i", "n" } },
						["<c-u>"] = { "list_up", mode = { "i", "n" } },
					}
				}
			}
		},
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
