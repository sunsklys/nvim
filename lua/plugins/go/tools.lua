return {
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    keys = {
      { "<leader>gt", function() vim.lsp.buf.code_action({ filter = function(a) return a.title:match("Add tags") or a.title:match("Remove tags") or a.title:match("Modify tags") end }) end, desc = "Go 修改结构体标签", ft = "go" },
      { "<leader>gi", function() vim.lsp.buf.code_action({ filter = function(a) return a.title:match("impl") end }) end, desc = "Go 实现接口", ft = "go" },
    },
  },
}
