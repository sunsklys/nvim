-- numb.nvim: 输入 :数字 跳转时实时预览目标行（LazyVim 无内置替代）
return {
  {
    "nacro90/numb.nvim",
    keys = ":",
    opts = {
      show_numbers = true,
      show_cursorline = true,
      number_only = false,
    },
  },
}
