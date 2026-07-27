return {
  {
    "saghen/blink.cmp",
    -- blink.cmp 官方推荐锁定主版本号（v2 含 breaking changes，用 1.* 防意外升级）
    version = "1.*",
    opts = {
      -- 主动启用 signature help（LazyVim extras/coding/blink.lua:86 默认注释掉，作为 experimental）
      signature = { enabled = true },
    },
  },
}
