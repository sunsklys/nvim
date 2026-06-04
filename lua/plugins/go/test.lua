return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      { "fredrikaverpil/neotest-golang" },
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
    },
    keys = {
      { "<leader>tt", function() require("neotest").run.run() end, desc = "运行最近测试" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "运行文件测试" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "测试列表" },
    },
  },
}
