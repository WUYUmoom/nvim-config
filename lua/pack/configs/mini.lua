-- === mini ===
local P = {
	name = "mini.nvim", -- 仓库名
}

-- 懒加载触发器
vim.api.nvim_create_autocmd({
	"UIEnter", -- vim.schedule(function()
}, {
	callback = function()
		vim.schedule(function()
			PackUtils.load(P, function()
				require('mini.surround').setup {
					mappings = {
						add = 's',     -- Add surrounding
						delete = 'sd', -- Delete surrounding
						find = 'sf',   -- Find surrounding (to the right)
						find_left = 'sF', -- Find surrounding (to the left)
						highlight = 'sh', -- Highlight surrounding
						replace = 'cs', -- Replace surrounding/change sround
						update_n_lines = 'sn', -- Update `n_lines`
					},
				}
			end)
		end)
	end
})

-- 懒加载触发器
-- vim.api.nvim_create_autocmd({
-- 	"InsertEnter", "CmdlineEnter", -- 补全/命令行
-- }, {
-- 	callback = function()
-- 		PackUtils.load(P, function()
-- 				require('mini.pairs').setup {}
-- 		end)
-- 	end
-- })
