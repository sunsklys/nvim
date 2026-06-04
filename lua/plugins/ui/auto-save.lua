return {
  {
    "snacks.nvim",
    keys = {
      { "<leader>ua", function() Snacks.toggle.option("autowrite", { off = false, name = "Auto Save" }):toggle() end, desc = "切换自动保存" },
    },
    init = function()
      vim.o.autowrite = true
    end,
  },
}
