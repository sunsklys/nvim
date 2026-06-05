return {
  {
    "nvim-neotest/neotest",
    keys = {
      { "<leader>tt", function() require("neotest").run.run() end, desc = "运行最近测试" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "运行文件测试" },
    },
  },
}
