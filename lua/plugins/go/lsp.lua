return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
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
