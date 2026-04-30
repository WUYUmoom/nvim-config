-- === LSP 核心配置 (Lspconfig + Mason) ===
if vim.g.vscode then return end

-- 环境探测：判断 CPU 架构，决定安装哪些 LSP
local arch = jit and jit.arch or ""
local is_arm = arch:match("arm") or arch:match("aarch64")

local servers = { "lua_ls", "rust_analyzer", "denols", "kotlin_language_server" }
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

            -- === 特定 LSP 配置 (使用 Neovim 0.11+ vim.lsp.config 语法) ===

            -- Python (pylsp) + uv 虚拟环境自适应
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

            -- Lua (lua_ls)
            vim.lsp.config("lua_ls", {
                settings = {
                    ["Lua"] = {
                        hint = { enable = true },
                        diagnostics = { globals = { "vim", "require", "opts", "PackUtils", "jit" } },
                    },
                },
            })

            -- Kotlin (kotlin_language_server) - 严格模式配置
            vim.lsp.config("kotlin_language_server", {
                settings = {
                    codelens = {
                        enable = true,
                    },
                    inlayHints = {
                        enable = true,
                        typeHints = true,
                        parameterHints = true,
                        chainingHints = true,
                    },
                    -- 启用更严格的诊断
                    diagnostics = {
                        enable = true,
                        -- 报告所有级别的问题
                        errorSeverity = "error",
                        warnSeverity = "warning",
                        infoSeverity = "information",
                        hintSeverity = "hint",
                    },
                    -- Kotlin 编译器选项
                    compiler = {
                        -- 启用所有警告
                        warningsAsErrors = false,            -- 设为 true 会将警告视为错误（最严格）
                        freeCompilerArgs = {
                            "-Xjsr305=strict",               -- 严格的 JSR-305 注解处理
                            "-Werror",                       -- 将警告视为错误（可选，非常严格）
                            "-Xopt-in=kotlin.RequiresOptIn", -- 需要显式选择加入实验性 API
                        },
                    },
                    -- 代码风格检查
                    codeStyle = {
                        enable = true,
                    },
                },
                -- 初始化选项
                init_options = {
                    storagePath = vim.fn.stdpath("data") .. "/kotlin-ls",
                },
                -- 根目录检测
                root_dir = function(fname)
                    return require("lspconfig.util").root_pattern(
                        "settings.gradle",
                        "settings.gradle.kts",
                        "build.gradle",
                        "build.gradle.kts",
                        "pom.xml",
                        ".git"
                    )(fname)
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
        end)
    end
})
