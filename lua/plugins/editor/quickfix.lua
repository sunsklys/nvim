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
      func_map = {
        open = "<CR>",
        tab = "t",
        split = "<C-x>",
        vsplit = "<C-v>",
        pscrollup = "<C-U>",
        pscrolldown = "<C-D>",
        ptoggleitem = "p",
        ptoggleauto = "P",
        ptogglemode = "zp",
        filter = "zn",
        filterr = "zN",
        sclear = "z<Space>",
        stogglebuf = "<Tab>",
        stogglevm = "<Space>",
        prevfile = "<C-p>",
        nextfile = "<C-n>",
        prevhist = "<",
        nexthist = ">",
      },
    },
  },
}
