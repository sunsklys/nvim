-- 测试覆盖率(配合 neotest -cover flag), <leader>tL/tC/tM
return {
  {
    "andythigpen/nvim-coverage",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "Coverage", "CoverageLoad", "CoverageShow", "CoverageHide", "CoverageToggle", "CoverageSummary" },
    opts = { auto_reload = true },
    keys = {
      { "<leader>tL", "<cmd>CoverageLoad<cr>", desc = "加载覆盖率文件" },
      { "<leader>tC", "<cmd>CoverageToggle<cr>", desc = "切换覆盖率显示" },
      { "<leader>tM", "<cmd>CoverageSummary<cr>", desc = "覆盖率摘要窗" },
    },
  },
}
