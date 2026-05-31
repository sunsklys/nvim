return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "leoluz/nvim-dap-go" },
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
    },
    keys = {
      { "<leader>db", "<cmd>DapToggleBreakpoint<CR>", desc = "切换断点" },
      { "<leader>dc", "<cmd>DapContinue<CR>", desc = "继续调试" },
      { "<leader>du", "<cmd>lua require('dapui').toggle()<CR>", desc = "调试界面" },
    },
  },
}
