return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      { "fredrikaverpil/neotest-golang" },
      { "nvim-neotest/nvim-nio" },
      { "nvim-lua/plenary.nvim" },
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-golang")({}),
        },
      })
    end,
    keys = {
      { "<leader>tt", function() require("neotest").run.run() end, desc = "运行最近测试" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "运行文件测试" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "测试列表" },
    },
  },
}
