return {
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      {
        "nvim-lua/plenary.nvim",
      },
    },
    event = "VeryLazy",
    opts = function()
      local null_ls = require("null-ls")
      return {
        sources = {
          null_ls.builtins.code_actions.gomodifytags,
          null_ls.builtins.code_actions.impl,
        },
      }
    end,
    keys = {
      { "<leader>gt", function() vim.lsp.buf.code_action({ filter = function(a) return a.title:match("Add tags") or a.title:match("Remove tags") or a.title:match("Modify tags") end }) end, desc = "Go 修改结构体标签", ft = "go" },
      { "<leader>gi", function() vim.lsp.buf.code_action({ filter = function(a) return a.title:match("impl") end }) end, desc = "Go 实现接口", ft = "go" },
    },
  },
}
