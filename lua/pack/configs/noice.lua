-- === noice ===
if vim.g.vscode then return end

local P = {
	name = "noice.nvim",
	module = "noice",
	deps = { "nui.nvim" },
}

-- 复刻 "VeryLazy" 策略
vim.api.nvim_create_autocmd("UIEnter", {
	callback = function()
		-- vim.schedule 的作用是：别卡住界面的渲染，等 UI 画完了、闲下来了，再偷偷加载
		vim.schedule(function()
			PackUtils.load(P, function(plugin)
				plugin.setup({
					presets = {
						bottom_search = true,                     -- use a classic bottom cmdline for search
						command_palette = true,                   -- position the cmdline and popupmenu together
						long_message_to_split = true,             -- long messages will be sent to a split
						inc_rename = false,                       -- enables an input dialog for inc-rename.nvim
						lsp_doc_border = false,                   -- add a border to hover docs and signature help
					},
					-- 需要过滤的信息
					routes = {
						{
							-- 过滤翻译插件的成功提示
							filter = {
								event = "msg_show",
								find = "Translate success",
							},
							-- opts.skip = true 会告诉 Noice 完全忽略这条消息
							opts = { skip = true },
						},
						{
							-- 过滤打开rust文件不影响使用的错误提示
							filter = {
								event = "msg_show",
								kind = "emsg",
								find = "Error in decoration provider",
							},
							opts = { skip = true },
						},
					},
				})
			end)
		end)
	end
})
