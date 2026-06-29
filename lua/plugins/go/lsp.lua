return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              -- 本仓库 additive 于 LazyVim 默认：shadow 是 LazyVim 不开的，其余 LazyVim 已提供
              analyses = {
                shadow = true, -- 检测变量遮蔽（range/len/type 等），LazyVim 默认不开
              },
              gofumpt = true, -- 比 gofmt 更严格（LazyVim 默认已开，此处显式声明本仓库偏好）
            },
          },
        },
      },

    },
  },
}
