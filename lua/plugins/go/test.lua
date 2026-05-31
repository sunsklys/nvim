return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      { "nvim-neotest/neotest-golang" },
      { "nvim-neotest/nvim-nio" },
      { "nvim-lua/plenary.nvim" },
    },
    keys = {
      { "<leader>tt", "<cmd>lua require('neotest').run.run()<CR>", desc = "运行最近测试" },
      { "<leader>tf", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<CR>", desc = "运行文件测试" },
      { "<leader>ts", "<cmd>lua require('neotest').summary.toggle()<CR>", desc = "测试列表" },
    },
  },
}
