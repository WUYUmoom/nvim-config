-- === 彩虹缩进 ===

local P = {
	name = "indent-blankline.nvim", -- 仓库名
}

-- 懒加载触发器
vim.api.nvim_create_autocmd({
	"BufReadPost", "BufNewFile" -- 处理普通的文本文件时也能显示基础线条
}, {
	callback = function()
		PackUtils.load(P, function()
			require("ibl").setup({
				enabled = false, -- 【修改】完全禁用缩进线
				exclude = {
					filetypes = { "dashboard" },
				},
			})
		end)
	end
})
