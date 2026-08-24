-- noice.nvim：关闭 LSP signature 渲染
-- blink.cmp signature 已显式启用（coding/blink.lua），两者同开会双浮窗渲染
-- （saghen/blink.cmp#2365 已知冲突）；保 blink 自动触发窗，noice 侧让位
return {
  "folke/noice.nvim",
  opts = {
    lsp = {
      signature = { enabled = false },
    },
  },
}
