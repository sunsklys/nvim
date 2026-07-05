-- 测试覆盖率显示(配合 neotest -cover flag)
-- 支持 Go (coverprofile) / Python (coverage.py) / JS (lcov) 等格式
-- 工作流:跑测试(<leader>tr)生成 coverage.out → <leader>tL 加载 → <leader>tC 切换显示
-- signcolumn 高亮:未覆盖行红色,覆盖行绿色(可定制)
-- <leader>tL 之后还可以 :CoverageSummary 弹摘要窗
return {
  {
    "andythigpen/nvim-coverage",
    version = "*",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "Coverage", "CoverageLoad", "CoverageShow", "CoverageHide", "CoverageToggle", "CoverageSummary" },
    opts = { auto_reload = true },
    keys = {
      { "<leader>tL", "<cmd>CoverageLoad<cr>", desc = "加载覆盖率文件" },
      { "<leader>tC", "<cmd>CoverageToggle<cr>", desc = "切换覆盖率显示" },
    },
  },
}
