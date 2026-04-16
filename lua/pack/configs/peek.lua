if vim.g.vscode then return end

local P = {
	name = "peek.nvim",
	-- 编译命令：需要环境中安装了 deno
	build_cmd = { "deno", "task", "--quiet", "build:fast" },
}

PackUtils.setup_listener(P.name, P.build_cmd)

-- 在插件未加载时，这些命令就存在了。一旦被调用，它们会先加载插件，再执行真正的功能。
vim.api.nvim_create_user_command("PeekOpen", function()
	PackUtils.load(P, function()
		require("peek").setup({
			port = 9000,
			-- app = { "zen", "-private-window" },
			-- app = { "firefox-esr", "-private-window" },
			app = { "chromium", "--app=http://localhost:9000/?theme=dark", "--incognito" },
		})
	end)
	require("peek").open()
end, { desc = "Lazy load and open Peek" })

vim.api.nvim_create_user_command("PeekClose", function()
	-- 如果插件没加载，Close 命令通常不需要做任何事，或者也触发加载
	if PackUtils.plugin_loaded[P.name] then
		require("peek").close()
	end
end, { desc = "Close Peek" })
