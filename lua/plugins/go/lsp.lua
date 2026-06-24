return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            analyses = {
              shadow = true,
              -- LazyVim go extra 默认未启用、实用的几个检查：
              unusedwrite = true, -- 检测无意义的重复写入（slice append 未使用返回值等）
              nilness = true,    -- nil 指针解引用 / impossible nil 比较
              useany = true,     -- interface{} 是否可换为 any
            },
            gofumpt = true,  -- 比 gofmt 更严格的格式化（社区标准）
          },
        },
      },

    },
  },
}
