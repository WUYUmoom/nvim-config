-- === LSP 核心配置 (Lspconfig + Mason) ===
if vim.g.vscode then return end
-- 强制设置 Java 环境
vim.env.JAVA_HOME = '/usr/lib/jvm/java-21-openjdk-amd64'
vim.env.PATH = vim.env.JAVA_HOME .. '/bin:' .. vim.env.PATH
-- 环境探测：判断 CPU 架构，决定安装哪些 LSP
local arch = jit and jit.arch or ""
local is_arm = arch:match("arm") or arch:match("aarch64")

local servers = { "lua_ls", "rust_analyzer", "denols", "kotlin_lsp" }

if not is_arm then
    vim.list_extend(servers, { "marksman", "svelte", "cssls", "html" })
end

-- 插件配置清单
local P = {
    name = "nvim-lspconfig",
    deps = { "mason.nvim", "mason-lspconfig.nvim", "inlay-hints.nvim" },
}

-- === 创建 :Mason 命令 ===
vim.api.nvim_create_user_command("Mason", function()
    require("mason.ui").open()
end, { desc = "Open Mason package manager UI" })

-- === 全局快捷键映射 ===
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<leader>h", vim.lsp.buf.hover, opts)         -- <space>h显示提示文档
vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)           -- gd跳转到定义
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)          -- gD跳转到声明(例如c语言中的头文件中的原型、一个变量的extern声明)
vim.keymap.set("n", "go", vim.lsp.buf.type_definition, opts)      -- go跳转到变量类型定义的位置(例如一些自定义类型)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)       -- <space>rn变量重命名
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)  -- 【修改】<space>ca 快速修复/导入类
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- <space>d浮动窗口显示所在行警告或错误信息
vim.keymap.set("n", "<leader>-", vim.diagnostic.goto_prev, opts)  -- <space>-跳转到上一处警告或错误的地方
vim.keymap.set("n", "<leader>=", vim.diagnostic.goto_next, opts)  -- <space>+跳转到下一处警告或错误的地方
-- vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)         -- gr跳转到引用了对应变量或函数的位置，改用snacks
-- vim.keymap.set({ 'n', 'x' }, '<leader>f', function() vim.lsp.buf.format({ async = true }) end, opts) -- <space>f进行代码格式化

-- 懒加载触发器：当打开文件时触发
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    callback = function()
        PackUtils.load(P, function()
            -- === 基础依赖初始化 (Mason) ===
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = servers,
            })
            require("inlay-hints").setup()

            -- === 全局诊断设置 ===
            vim.diagnostic.config({
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "✘",
                        [vim.diagnostic.severity.WARN] = "▲",
                        [vim.diagnostic.severity.HINT] = "⚑",
                        [vim.diagnostic.severity.INFO] = "»",
                    },
                },
                -- 虚拟文本显示（行尾的错误提示）
                virtual_text = {
                    spacing = 4,
                    prefix = "●",
                    source = "if_many", -- 当有多个来源时显示来源
                },
                -- 下划线样式
                underline = true,
                -- 更新延迟（毫秒）
                update_in_insert = false,
                -- 严重性顺序
                severity_sort = true,
                -- 浮动窗口配置
                float = {
                    border = "rounded",
                    source = "always",
                    header = "",
                    prefix = "",
                },
            })

            -- Kotlin 特定的诊断配置（更严格）
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "kotlin",
                callback = function()
                    -- 为 Kotlin 文件设置更严格的诊断
                    vim.diagnostic.config({
                        virtual_text = {
                            spacing = 2,
                            prefix = "▶",
                            source = "always", -- 总是显示来源
                        },
                        severity_sort = true,
                        signs = true,
                        underline = true,
                    }, 0) -- 0 表示当前 buffer

                    vim.notify("✅ Kotlin 严格诊断模式已启用", vim.log.levels.INFO)
                end,
            })
            -- === 特定 LSP 配置 (使用 Neovim 0.11+ vim.lsp.config 语法) ===
            vim.lsp.config("pylsp", {
                on_init = function(client)
                    -- 1. 安全获取 root_dir
                    local root_dir = client.config.root_dir
                    -- 2. 只有当 root_dir 不为 nil 时才进行后续探测
                    if root_dir then
                        local venv_python = root_dir .. "/.venv/bin/python"
                        -- 3. 检查虚拟环境文件是否真的存在且可读
                        if vim.fn.filereadable(venv_python) == 1 then
                            client.config.settings.pylsp.plugins.jedi.environment = venv_python
                            -- 只有修改了设置才发送通知
                            client.notify("workspace/didChangeConfiguration", {
                                settings = client.config.settings
                            })
                        end
                    end
                    -- 无论是否找到虚拟环境，都返回 true 让 LSP 继续启动
                    return true
                end,
                settings = {
                    pylsp = {
                        plugins = {
                            jedi = { environment = nil }
                        }
                    }
                },
            })

            -- Kotlin LSP 配置
            vim.lsp.config("kotlin-lsp", {
                cmd = {
                    "-Xms256m",  -- 初始堆内存
                    "-Xmx2g",    -- 最大堆内存（根据项目大小调整，2-4g 比较合理）
                    "-XX:+UseG1GC",  -- 使用 G1 垃圾回收器
                    "-XX:MaxGCPauseMillis=20",  -- 控制 GC 停顿时间
                    "-XX:+TieredCompilation",  -- 启用分层编译
                    "-XX:+UseStringDeduplication",
                    "kotlin-lsp",
                    "--stdio" },
                root_markers = {
		            "settings.gradle", -- Gradle (multi-project)
		            "settings.gradle.kts", -- Gradle (multi-project)
		            "pom.xml", -- Maven
		            "build.gradle", -- Gradle
		            "build.gradle.kts", -- Gradle
	        	    "workspace.json", -- Used to integrate your own build system
	            },
                filetypes = { "kotlin" },    -- 明确限制文件类型
            })
            -- === 自动整理 Kotlin Import ===
            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = "*.kt",
                callback = function()
                    vim.lsp.buf.code_action({
                        context = { only = { "source.organizeImports" } },
                    })
                end,
            })
            -- Go (gopls)
            vim.lsp.config("gopls", {
                settings = {
                    ["gopls"] = {
                        hints = {
                            rangeVariableTypes = true,
                            parameterNames = true,
                            constantValues = true,
                            assignVariableTypes = true,
                            compositeLiteralFields = true,
                            compositeLiteralTypes = true,
                            functionTypeParameters = true,
                        },
                    },
                },
            })

            -- 遍历列表并正式启用服务器
            for _, server in ipairs(servers) do
                vim.lsp.enable(server)
            end
            vim.diagnostic.config({
                virtual_text = true,
                update_in_insert = true,
            })
        end)
    end
})
