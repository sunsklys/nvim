return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
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
