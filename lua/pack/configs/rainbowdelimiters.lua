-- === 彩虹括号 ===
local P = {
	name = "rainbow-delimiters.nvim",
}

-- 懒加载触发器
vim.api.nvim_create_autocmd({
	"UIEnter", -- vim.schedule(function()
}, {
	callback = function()
		vim.schedule(function()
			PackUtils.load(P, function()
				require("rainbow-delimiters.setup").setup({
					highlight = {
						"RainbowDelimiterBlue",
						"RainbowDelimiterViolet",
						"RainbowDelimiterRed",
						"RainbowDelimiterYellow",
						"RainbowDelimiterGreen",
						"RainbowDelimiterOrange",
						"RainbowDelimiterCyan",
					},
				})
			end)
		end)
	end
})
