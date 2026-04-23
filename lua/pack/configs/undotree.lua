-- === undotree ===
local P = {
	name = "undotree",
}

-- 快捷键触发
vim.keymap.set({ "n", "x" }, "<leader>t", function()
	PackUtils.load(P, function()
		require('undotree').setup({
			keymaps = {
				["e"] = "move_next",
				["u"] = "move_prev",
				["n"] = "move2parent",
				-- ["E"] = "move_change_next",
				-- ["U"] = "move_change_prev",
				["<cr>"] = "action_enter",
				["i"] = "action_enter",
				["d"] = "enter_diffbuf",
				["q"] = "quit",
				["S"] = "update_undotree_view",
			},
		})
	end)
	require('undotree').toggle()
end, { desc = "toggle undotree" })
