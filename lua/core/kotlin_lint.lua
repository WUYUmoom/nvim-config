local M = {}

-- 运行 detekt 检查
function M.run_detekt()
    local bufnr = vim.api.nvim_get_current_buf()
    local filepath = vim.api.nvim_buf_get_name(bufnr)
    local project_root = vim.fn.fnamemodify(filepath, ':h')

    -- 查找项目根目录（包含 detekt.yml 或 build.gradle 的目录）
    while project_root ~= '/' do
        if vim.fn.filereadable(project_root .. '/detekt.yml') == 1 or
            vim.fn.filereadable(project_root .. '/build.gradle') == 1 or
            vim.fn.filereadable(project_root .. '/build.gradle.kts') == 1 then
            break
        end
        project_root = vim.fn.fnamemodify(project_root, ':h')
    end

    if project_root == '/' then
        vim.notify("❌ 未找到 Kotlin 项目根目录", vim.log.levels.ERROR)
        return
    end

    vim.notify("🔍 运行 detekt 检查...", vim.log.levels.INFO)

    -- 异步执行 detekt
    vim.system({
        'detekt',
        '--input', filepath,
        '--config', project_root .. '/detekt.yml',
        '--report', 'txt:stdout'
    }, {
        cwd = project_root,
    }, function(result)
        if result.code == 0 then
            vim.notify("✅ detekt 检查通过！", vim.log.levels.INFO)
        else
            -- 解析输出并显示问题
            local output = result.stdout or ""
            vim.schedule(function()
                -- 在分割窗口中显示结果
                vim.cmd('split | enew')
                vim.bo.filetype = 'qf'
                vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(output, '\n'))
                vim.cmd('setlocal nomodifiable')
                vim.cmd('resize 10')
            end)
        end
    end)
end

-- 运行 ktlint 检查
function M.run_ktlint()
    local bufnr = vim.api.nvim_get_current_buf()
    local filepath = vim.api.nvim_buf_get_name(bufnr)

    vim.notify("🔍 运行 ktlint 检查...", vim.log.levels.INFO)

    vim.system({
        'ktlint',
        filepath
    }, {}, function(result)
        if result.code == 0 then
            vim.notify("✅ ktlint 检查通过！", vim.log.levels.INFO)
        else
            local output = result.stderr or result.stdout or ""
            vim.schedule(function()
                vim.notify("⚠️ ktlint 发现问题:\n" .. output, vim.log.levels.WARN)
            end)
        end
    end)
end

-- 设置快捷键
function M.setup()
    vim.keymap.set('n', '<Leader>kd', M.run_detekt, {
        desc = '运行 detekt 检查',
        buffer = true
    })

    vim.keymap.set('n', '<Leader>kk', M.run_ktlint, {
        desc = '运行 ktlint 检查',
        buffer = true
    })
end

return M
