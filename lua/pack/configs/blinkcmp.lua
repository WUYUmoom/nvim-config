-- === 自动补全插件 (Blink.cmp) ===
if vim.g.vscode then return end

local P = {
	name = "blink.cmp",
	module = "blink.cmp",
	deps = { "friendly-snippets" },
	-- build_cmd = "cargo build --release",
}

-- PackUtils.setup_listener(P.name, P.build_cmd)

vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter", "LspAttach" }, {
	once = true,
	callback = function()
		-- 调用引擎的 load 方法，把 setup 逻辑作为匿名函数传进去
		PackUtils.load(P, function(plugin)
			plugin.setup({
				fuzzy = {
					prebuilt_binaries = {
						force_version = 'v*',
					},
				},
				cmdline = {
					-- keymap = { ["<CR>"] = { "select_and_accept", "fallback" } },
					completion = {
						list = { selection = { preselect = false, auto_insert = true } },
						menu = { auto_show = function() return vim.fn.getcmdtype() == ":" end },
						ghost_text = { enabled = false },
					},
				},
				keymap = {
					preset = "none",
					["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
					["<CR>"] = { "accept", "fallback" },
					["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
					["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
					["<C-b>"] = { "scroll_documentation_up", "fallback" },
					["<C-f>"] = { "scroll_documentation_down", "fallback" },
					["<C-e>"] = { "snippet_forward", "select_next", "fallback" },
					["<C-u>"] = { "snippet_backward", "select_prev", "fallback" },
				},
				completion = {
					keyword = { range = "full" },
					documentation = { auto_show = true, auto_show_delay_ms = 0 },
					list = { selection = { preselect = false, auto_insert = false } },
				},
				enabled = function()
					return not vim.tbl_contains({}, vim.bo.filetype)
							and vim.bo.buftype ~= "prompt"
							and vim.b.completion ~= false
				end,
				appearance = {
					use_nvim_cmp_as_default = true,
					nerd_font_variant = "mono",
				},
				sources = {
					default = { "buffer", "lsp", "path", "snippets" },
					providers = {
						buffer = { score_offset = 5 },
						path = { score_offset = 3 },
						lsp = { score_offset = 2 },
						snippets = { score_offset = 1 },
						-- cmdline = { -- 输入超过3个及以上字母才触发补全
						-- 	min_keyword_length = function(ctx)
						-- 		if ctx.mode == "cmdline" and string.find(ctx.line, " ") == nil then return 3 end
						-- 		return 0
						-- 	end,
						-- },
					},
				},
			})
		end)
	end
})
