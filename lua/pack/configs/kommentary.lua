-- 注释快捷键
local map = require("core.keymap")
map:key("n", "<space>cn", "<Plug>kommentary_line_increase")
map:key("x", "<space>cn", "<Plug>kommentary_visual_increase<esc>") -- 选择模式下注释/反注释后退出该模式
map:key("n", "<space>cu", "<Plug>kommentary_line_decrease")
map:key("x", "<space>cu", "<plug>kommentary_visual_decrease<esc>")

local P = {
	name = "b3nj5m1n/kommentary", -- 仓库名
	module = "kommentary.config", -- require模块名
}

-- 懒加载触发器
vim.api.nvim_create_autocmd({
	"UIEnter",
}, {
	callback = function()
		vim.schedule(function()
			PackUtils.load(P, function(plugin)
				plugin.configure_language("default", {
					prefer_single_line_comments = true,
				})
			end)
		end)
	end
})
