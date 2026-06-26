-- numb.nvim: 输入 :数字 跳转时，在命令行上方实时显示目标行预览 + 文件总行数
-- 纯增量，LazyVim 无内置替代
-- （源码验证：grep -r "numb" ~/.local/share/nvim/lazy/LazyVim/lua/ 无结果）
return {
  {
    "nacro90/numb.nvim",
    event = "VeryLazy",
    opts = {
      show_numbers = true,
      show_cursorline = true,
      number_only = false,
    },
  },
}
