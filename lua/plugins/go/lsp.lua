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
                fieldalignment = true,
              },
              vulncheck = "Imports",
            },
          },
        },
      },
      setup = {
        gopls = function(_, opts)
          Snacks.util.lsp.on({ name = "gopls" }, function(_, client)
            if not client.server_capabilities.semanticTokensProvider then
              local legend = vim.tbl_get(client, "config", "capabilities", "textDocument", "semanticTokens")
              if legend then
                client.server_capabilities.semanticTokensProvider = {
                  full = true,
                  legend = {
                    tokenTypes = legend.tokenTypes,
                    tokenModifiers = legend.tokenModifiers,
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
