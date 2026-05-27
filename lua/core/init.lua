-- ===
-- === Editor behavior
-- ===

-- 关闭底部状态栏
vim.o.laststatus = 0
-- 开启左侧数字
vim.o.number = true
-- 使用相对数
vim.o.relativenumber = false
-- 高亮当前行
vim.o.cursorline = false
-- 一行不能完全显示时自动换行
vim.o.wrap = true
-- 在最后一行显示一些内容
vim.o.showcmd = true
-- 命令模式显示补全菜单
vim.o.wildmenu = true
-- /搜索时忽略大小写
vim.o.ignorecase = true
-- /搜索时智能大小写
vim.o.smartcase = true
-- 共享系统剪切
--vim.o.clipboard = 'unnamedplus'
-- 设置<tab>键
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
-- 随文件自动更改当前路径
vim.o.autochdir = true
-- 在光标上方和下方保留的最小屏幕行数
vim.o.scrolloff = 4
-- 自动缩进
vim.o.smartindent = true
-- 100毫秒没有输入文件将会自动保存交换文件
vim.o.updatetime = 100
-- 开启鼠标
vim.o.mouse = 'a'
-- 开启颜色
vim.o.termguicolors = true
-- 将updatetime设置为较低的值以提高性能
vim.opt.updatetime = 200
-- 指定keyword
vim.opt.iskeyword = "_,49-57,A-Z,a-z"
-- 让全局默认边框变成rounded或single
vim.o.winborder = 'rounded'
-- 始终隐藏字符（不依赖语法高亮）,在 Markdown 文件中，粗体、斜体等标记字符可能会被隐藏
-- vim.opt.conceallevel = 2

-- 设置编码格式
vim.o.fileencodings = 'utf-8,gb2312,gb18030,gbk,ucs-bom,cp936,latin1'
vim.o.enc = 'utf8'

-- 保存修改历史
vim.o.swapfile = true
vim.o.undofile = true

-- 保存折叠记录，在某些独立的窗口会报错
-- vim.cmd 'au BufWinLeave * silent mkview'
-- vim.cmd 'au BufWinEnter * silent loadview'

-- 打开文件时进入上次编辑的位置
vim.cmd([[au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif]])

-- fcitx5在normal模式时自动切换为英文输入法,摘自fcitx5的archwiki
vim.cmd([[
autocmd InsertLeave * :silent !fcitx5-remote -c
autocmd BufCreate *  :silent !fcitx5-remote -c
autocmd BufEnter *  :silent !fcitx5-remote -c
autocmd BufLeave *  :silent !fcitx5-remote -c
]])
-- 意为: 当 进入插入模式、创建Buf、进入Buf、离开Buf 时 触发shell命令 fcitx-remote -c 关闭输入法，改为英文输入

-- 日志高亮关键字
vim.filetype.add({
	extension = { -- 后缀名
		log = "log",
		txt = function(path)
			if path:match(".*%.log") then
				return "log"
			end
			return "text"
		end,
	},
	filename = { -- 文件名
		["messages"] = "log",
		["syslog"] = "log",
	},
})
local log_group = vim.api.nvim_create_augroup("LogHighlighting", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = log_group,
	pattern = "log",
	callback = function()
		-- 这里的 fg 是十六进制颜色，你可以根据喜好调整
		vim.api.nvim_set_hl(0, "LogVersion", { fg = "#50FA7B", bold = true }) -- 绿色
		vim.api.nvim_set_hl(0, "LogDownloaded", { fg = "#BD93F9" })      -- 紫色
		vim.api.nvim_set_hl(0, "LogCompiling", { fg = "#F1FA8C" })       -- 黄色
		vim.api.nvim_set_hl(0, "LogFinished", { fg = "#8BE9FD", bold = true }) -- 青色
		-- 清除旧的匹配，防止重复渲染卡顿
		for _, match in ipairs(vim.fn.getmatches()) do
			if match.group:find("^Log") then
				vim.fn.matchdelete(match.id)
			end
		end
		-- 版本号匹配
		vim.fn.matchadd("LogVersion", [[v\d\+\.\d\+\.\d\+]])
		-- \V 表示 "very nomagic"直接匹配字面量，\c 表示不区分大小写，\S* 匹配零个或多个“非空白”字符
		vim.fn.matchadd("LogDownloaded", [[\c\S*download\S*]])
		vim.fn.matchadd("LogCompiling", [[\VCompiling]])
		vim.fn.matchadd("LogFinished", [[\c\S*finish\S*]])
	end,
})

-- 开启高亮复制
vim.cmd([[au TextYankPost * silent! lua vim.highlight.on_yank()]])
-- === 新增：Kotlin 文件自动补全包名和类名 ===
local kotlin_template_applied = {} -- 记录已应用的 buffer，防止重复

vim.api.nvim_create_autocmd("FileType", {
	pattern = "kotlin",
	callback = function(args)
		local buf = args.buf

		-- 如果已经应用过模板，跳过
		if kotlin_template_applied[buf] then return end

		-- 检查文件是否为空（只有新创建的空文件才应用模板）
		local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		local is_empty = true
		for _, line in ipairs(lines) do
			if line:match("%S") then -- 如果有非空白字符
				is_empty = false
				break
			end
		end

		if not is_empty then
			kotlin_template_applied[buf] = true
			return
		end

		-- 获取完整文件路径
		local full_path = vim.api.nvim_buf_get_name(buf)
		local filename = vim.fn.fnamemodify(full_path, ":t:r") -- 文件名（不含扩展名）

		-- 尝试匹配 kotlin/ 目录
		local package_name = ""
		local kotlin_index = full_path:find("/kotlin/")
		if kotlin_index then
			local after_kotlin = full_path:sub(kotlin_index + 8) -- 跳过 "/kotlin/"
			-- 去掉文件名部分，只保留目录
			local last_slash = after_kotlin:reverse():find("/")
			if last_slash then
				local dir_part = after_kotlin:sub(1, #after_kotlin - last_slash)
				package_name = dir_part:gsub("/", ".")
			end
		end

		-- 构建模板内容
		local template_lines = {}
		if package_name ~= "" and package_name ~= "." then
			table.insert(template_lines, "package " .. package_name)
			table.insert(template_lines, "")
		end
		table.insert(template_lines, "class " .. filename .. " {")
		table.insert(template_lines, "    ")
		table.insert(template_lines, "}")

		-- 写入缓冲区
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, template_lines)

		-- 标记已应用
		kotlin_template_applied[buf] = true

		-- 光标定位到类体内的空行
		local cursor_line = package_name ~= "" and package_name ~= "." and 4 or 2
		vim.api.nvim_win_set_cursor(0, { cursor_line, 4 })

		-- 调试信息（可以在 :messages 中查看）
		vim.notify("✅ Kotlin 模板已应用到: " .. filename, vim.log.levels.INFO)
	end,
})
-- 主题颜色
vim.cmd.colorscheme("catppuccin")
