if vim.g.vscode then return end

local P = {
	name = "code_runner.nvim",
	deps = {},
}

-- 定义映射配置表
local mappings = {
	{ ft = { "rust", "python" }, cmd = "RunCode",                         desc = "Save and Run Code" },
	{ ft = "markdown",           cmd = "PeekToggle",              desc = "Reload Markdown Preview" },
	{ ft = "dart",               cmd = "Telescope flutter commands",      desc = "Open Flutter Commands" },
	{ ft = "go",                 cmd = "set splitbelow;sp;term go run %", desc = "Run Go file" },
}

-- 只有进入这些文件类型时，才会为当前 buffer 绑定 r 键
local ft_group = vim.api.nvim_create_augroup("CodeRunnerLazy", { clear = true })

for _, entry in ipairs(mappings) do
	vim.api.nvim_create_autocmd("FileType", {
		pattern = entry.ft,
		group = ft_group,
		callback = function(args)
			-- 为当前 buffer 绑定 r 键
			vim.keymap.set("n", "r", function()
				if vim.bo.modified then vim.cmd("wall") end
				-- 只有命令中包含 "RunCode" 时，才加载代码运行器插件
				if string.find(entry.cmd, "RunCode") then
					PackUtils.load(P, function()
						require("code_runner").setup({
							-- project = {
							-- 	["~/sixsixsix"] = {
							-- 		name = "sixsixsix",
							-- 		description = "六爻网页排盘",
							-- 		command = "cargo run --release"
							-- 	},
							-- },
							filetype = {
								python = "uv run $fileName",
								rust = { "cargo run --release" },
							},
						})
					end)
				end
				-- 处理多条命令的情况 (用分号分隔)
				for c in string.gmatch(entry.cmd, "[^;]+") do
					vim.cmd(c)
				end
			end, { buffer = args.buf, desc = entry.desc, silent = true })
		end,
	})
end
