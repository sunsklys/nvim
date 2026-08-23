return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          -- 不走 mason：registry 钉的 v0.23.0 在 go 1.26 装不上，而 LazyVim 的 use_mason 路径
          -- 依赖包装好才 automatic_enable——包缺失时 gopls 永不 attach（2026-08 全新数据目录后实测）
          -- 系统 ~/go/bin/gopls 由 PATH 提供，直接 vim.lsp.enable
          mason = false,
          settings = {
            gopls = {
              -- 增量于 LazyVim 默认：shadow 是唯一额外开启的 analysis
              analyses = {
                shadow = true,
              },
            },
          },
        },
      },
    },
  },
}
