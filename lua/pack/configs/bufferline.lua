local map = require("core.keymap")
-- 新建空缓冲区，neovim自带的
map:cmd('tu', 'enew')
-- 关闭当前缓冲区，neovim自带的，完整命令bdelete
map:cmd('tq', 'bd')

-- === 顶部标签栏 (Bufferline) ===
if vim.g.vscode then return end

local P = {
	name = "bufferline.nvim",
	deps = { "nvim-web-devicons" }, -- 确保图标库先加载
}

-- 懒加载触发器：打开或新建文件时触发
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	once = true,
	callback = function()
		PackUtils.load(P, function()
			-- 在缓冲区之间移动
			map:cmd('tn', 'BufferLineCyclePrev')
			map:cmd('ti', 'BufferLineCycleNext')

			-- 移动缓冲区的位置
			map:cmd('tmn', 'BufferLineMovePrev')
			map:cmd('tmi', 'BufferLineMoveNext')

			-- 关闭缓冲区
			map:cmd('tN', 'BufferLineCloseLeft')
			map:cmd('tI', 'BufferLineCloseRight')
			map:cmd('tQ', 'BufferLineCloseOthers')
			require("bufferline").setup({
				options = {
					modified_icon = "",
					buffer_close_icon = "×",
					-- show_buffer_close_icons = false,
					max_name_length = 14,
					max_prefix_length = 13,
					tab_size = 10,
					indicator = {
						style = "none",
					},
				},
			})
		end)
	end
})
