return {
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "gopls",
        "delve",
        "golangci-lint",
        "gotests",
        "gomodifytags",
        "impl",
        "goimports",
        "gofumpt",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
                shadow = true,
                fieldalignment = true,
                nilness = true,
                unusedwrite = true,
                useany = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              gofumpt = true,
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true,
              vulncheck = "Imports",
            },
          },
        },
      },
    },
  },
}
