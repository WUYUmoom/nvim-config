-- Kotlin 自定义高亮配置
local M = {}

function M.setup()
  -- 为 Kotlin 设置更醒目的高亮
  local highlight_groups = {
    -- 关键字 - 使用粗体
    ["@keyword.kotlin"] = { fg = "#FF79C6", bold = true },
    ["@keyword.function.kotlin"] = { fg = "#BD93F9", italic = true },
    ["@keyword.return.kotlin"] = { fg = "#FF79C6", bold = true },
    
    -- 类型 - 使用不同颜色
    ["@type.kotlin"] = { fg = "#8BE9FD", italic = true },
    ["@type.builtin.kotlin"] = { fg = "#8BE9FD", bold = true },
    ["@type.parameter.kotlin"] = { fg = "#FFB86C" },
    
    -- 函数调用
    ["@function.kotlin"] = { fg = "#50FA7B" },
    ["@function.builtin.kotlin"] = { fg = "#50FA7B", italic = true },
    ["@function.call.kotlin"] = { fg = "#50FA7B" },
    ["@method.kotlin"] = { fg = "#50FA7B" },
    
    -- 属性与变量
    ["@property.kotlin"] = { fg = "#F1FA8C" },
    ["@variable.kotlin"] = { fg = "#F8F8F2" },
    ["@variable.parameter.kotlin"] = { fg = "#FFB86C", italic = true },
    ["@variable.builtin.kotlin"] = { fg = "#FFB86C" },
    
    -- 常量
    ["@constant.kotlin"] = { fg = "#BD93F9", bold = true },
    ["@constant.builtin.kotlin"] = { fg = "#BD93F9", bold = true },
    
    -- 字符串与字符
    ["@string.kotlin"] = { fg = "#F1FA8C" },
    ["@string.escape.kotlin"] = { fg = "#FF79C6", bold = true },
    ["@character.kotlin"] = { fg = "#F1FA8C" },
    
    -- 数字
    ["@number.kotlin"] = { fg = "#BD93F9" },
    ["@number.float.kotlin"] = { fg = "#BD93F9" },
    
    -- 运算符与标点
    ["@operator.kotlin"] = { fg = "#FF79C6", bold = true },
    ["@punctuation.bracket.kotlin"] = { fg = "#F8F8F2", bold = true },
    ["@punctuation.delimiter.kotlin"] = { fg = "#F8F8F2" },
    
    -- 注释 - 更明显的样式
    ["@comment.kotlin"] = { fg = "#6272A4", italic = true },
    ["@comment.documentation.kotlin"] = { fg = "#6272A4", italic = true },
    
    -- 注解
    ["@attribute.kotlin"] = { fg = "#50FA7B", italic = true },
    
    -- 条件与循环
    ["@conditional.kotlin"] = { fg = "#FF79C6", bold = true },
    ["@repeat.kotlin"] = { fg = "#FF79C6", bold = true },
    
    -- 异常处理
    ["@exception.kotlin"] = { fg = "#FF5555", bold = true },
    
    -- 命名空间与包
    ["@namespace.kotlin"] = { fg = "#8BE9FD" },
    ["@module.kotlin"] = { fg = "#8BE9FD" },
  }
  
  -- 应用高亮
  for group, opts in pairs(highlight_groups) do
    vim.api.nvim_set_hl(0, group, opts)
  end
  
  -- 为 nullability 类型添加特殊高亮 (?String, Int? 等)
  vim.api.nvim_set_hl(0, "@type.nullable.kotlin", { 
    fg = "#8BE9FD", 
    italic = true, 
    underline = true 
  })
end

return M
