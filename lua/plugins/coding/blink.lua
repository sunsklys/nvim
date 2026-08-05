return {
  {
    "saghen/blink.cmp",
    -- 锁定主版本号，防 v2 breaking 意外升级
    version = "1.*",
    opts = {
      signature = { enabled = true },
    },
  },
}
