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
      setup = {
        gopls = function(_, _)
          Snacks.util.lsp.on({ name = "gopls" }, function(_, client)
            if not client.server_capabilities.semanticTokensProvider then
              local caps = client.config.capabilities
              local semantic = caps
                  and caps.textDocument
                  and caps.textDocument.semanticTokens
              if semantic and semantic.tokenTypes then
                client.server_capabilities.semanticTokensProvider = {
                  full = true,
                  legend = {
                    tokenTypes = semantic.tokenTypes,
                    tokenModifiers = semantic.tokenModifiers,
                  },
                  range = true,
                }
              end
            end
          end)
        end,
      },
    },
  },
}
