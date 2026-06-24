return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    opts = {
      signature = { enabled = true },
      completion = {
        -- 选中候选时自动显示 LSP 文档（blink 默认 false 需手动 C-Space 触发）
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200, -- 200ms 延迟，牺牲即时性换取光标快速移动时不闪烁
        },
      },
    },
  },
}
