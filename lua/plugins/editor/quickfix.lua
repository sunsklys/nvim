-- Quickfix 列表增强：带预览、过滤、标记
-- 自动在 quickfix/window 打开时启用
--
-- 场景：grep 搜索结果、编译错误、diagnostics 聚合
return {
  {
    "kevinhwang91/nvim-bqf",
    event = "LazyFile",
    ft = "qf", -- 只在 quickfix 窗口加载
    opts = {
      auto_enable = true,
      preview = {
        win_height = 12,
        win_vheight = 12,
        delay_syntax = 80, -- 语法高亮延迟（ms），降低大文件卡顿
        border_chars = { "┃", "┃", "━", "━", "┏", "┓", "┗", "┛", "█" },
      },
      -- 快捷键（在 quickfix 窗口内）
      func_map = {
        open = "<CR>", -- 打开（当前窗口）
        tab = "t", -- 新 tab 打开
        split = "<C-x>", -- 水平分屏
        vsplit = "<C-v>", -- 垂直分屏
        pscrollup = "<C-U>", -- 预览向上滚
        pscrolldown = "<C-D>", -- 预览向下滚
        ptoggleitem = "p", -- 切换预览（跟随光标）
        ptoggleauto = "P", -- 切换自动预览
        ptogglemode = "zp", -- 切换预览模式（full/short）
        filter = "zn", -- 过滤保留当前项
        filterr = "zN", -- 过滤排除当前项
        sclear = "z<Space>", -- 清除过滤
        stogglebuf = "<Tab>", -- 标记整个 buffer
        stogglevm = "<Space>", -- 标记/取消标记（visual mode）
        prevfile = "<C-p>", -- 上一个文件
        nextfile = "<C-n>", -- 下一个文件
        prevhist = "<", -- 上一条 quickfix 历史
        nexthist = ">", -- 下一条 quickfix 历史
      },
    },
  },
}
