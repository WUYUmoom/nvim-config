-- 基本配置
require("core.init")

-- 基本键盘映射
require("core.keymap")

-- vim综合症
require("core.cursor")

-- markdown snippets
require("core.md-snippets")

-- markdown table fromat
require("core.markdown_table_format")

-- 安装的插件
require("pack.plugins")

-- 本地备份配置方式如下
-- # required
-- mv ~/.config/nvim{,.bak}
-- # optional but recommended
-- mv ~/.local/share/nvim{,.bak}
-- mv ~/.local/state/nvim{,.bak}
-- mv ~/.cache/nvim{,.bak}
vim.g.clipboard = {
  name = 'xclip', -- 如果你安装的是 xclip
  copy = {
    ['+'] = 'xclip -selection clipboard',
    ['*'] = 'xclip -selection primary',
  },
  paste = {
    ['+'] = 'xclip -selection clipboard -o',
    ['*'] = 'xclip -selection primary -o',
  },
  cache_enabled = 1,
}
