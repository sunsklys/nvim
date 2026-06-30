return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              -- 本仓库 additive 于 LazyVim 默认：shadow 是 LazyVim 不开的唯一增量（unusedwrite/nilness/useany/gofumpt 均为 LazyVim 默认）
              analyses = {
                shadow = true, -- 检测变量遮蔽（range/len/type 等）
              },
            },
          },
        },
      },
    },
  },
}
