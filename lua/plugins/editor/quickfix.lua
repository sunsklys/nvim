-- Quickfix 列表增强：预览、过滤、标记
return {
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    opts = {
      preview = {
        win_height = 12,
        win_vheight = 12,
        delay_syntax = 80, -- 语法高亮延迟（ms），降低大文件卡顿
        -- nvim-bqf 用 border 字段，原 border_chars 是无效 key 被静默忽略
        border = { "━", "┓", "┃", "┛", "━", "┗", "┃", "┏" },
      },
      -- 只保留真自定义 4 键；其余 14 键与 bqf 上游默认逐字相同（bqf config.lua:26-52），
      -- lazy opts deep-merge 下删去后行为不变（未覆盖的键继承默认）
      func_map = {
        pscrollup = "<C-U>", -- 默认 <C-b>，对齐 Vim 滚动语义
        pscrolldown = "<C-D>", -- 默认 <C-f>
        sclear = "z<Space>", -- 默认 z<Tab>，避开 stogglebuf 的 <Tab>
        stogglevm = "<Space>", -- 默认 <Tab>，visual 模式选中标记
      },
    },
  },
}
