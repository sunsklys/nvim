-- numb.nvim: 输入 :数字 跳转时实时预览目标行（LazyVim 无内置替代）
return {
  {
    "nacro90/numb.nvim",
    keys = ":",
    -- opts 三项（show_numbers/show_cursorline/number_only）均为上游默认值，不覆盖
  },
}
