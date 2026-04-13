-- === noice ===
if vim.g.vscode then return end

local P = {
	name = "noice.nvim",
	deps = { "nui.nvim" },
}

-- 比其他插件更早启动才能捕获错误、警告等信息，这里不配置懒加载
PackUtils.load(P, function()
	require("noice").setup({
		presets = {
			bottom_search = true,      -- use a classic bottom cmdline for search
			command_palette = true,    -- position the cmdline and popupmenu together
			long_message_to_split = true, -- long messages will be sent to a split
			inc_rename = false,        -- enables an input dialog for inc-rename.nvim
			lsp_doc_border = false,    -- add a border to hover docs and signature help
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
