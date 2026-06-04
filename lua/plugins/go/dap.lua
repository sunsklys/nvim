return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "leoluz/nvim-dap-go" },
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "切换断点" },
      { "<leader>dc", function() require("dap").continue() end, desc = "继续调试" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "调试界面" },
    },
    config = function()
      require("dapui").setup()
    end,
  },
}
