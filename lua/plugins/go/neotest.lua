-- neotest 跑测试前 silent! wall：autowrite=false 后兜底，避免 buffer 未落盘旧代码被测试
local function with_save(fn)
  return function()
    vim.cmd("silent! wall")
    fn()
  end
end

return {
  {
    "nvim-neotest/neotest",
    opts = {
      adapters = {
        ["neotest-golang"] = {
          go_test_args = { "-v", "-count=1", "-timeout=60s", "-cover" },
        },
      },
    },
    -- 覆盖 LazyVim 默认测试键，加 pre-run wall
    keys = {
      {
        "<leader>tt",
        with_save(function()
          require("neotest").run.run(vim.fn.expand("%"))
        end),
        desc = "Run File (Neotest, with save)",
      },
      {
        "<leader>tT",
        with_save(function()
          require("neotest").run.run(vim.uv.cwd())
        end),
        desc = "Run All Test Files (with save)",
      },
      {
        "<leader>tr",
        with_save(function()
          require("neotest").run.run()
        end),
        desc = "Run Nearest (with save)",
      },
      {
        "<leader>tl",
        with_save(function()
          require("neotest").run.run_last()
        end),
        desc = "Run Last (with save)",
      },
      {
        "<leader>tw",
        with_save(function()
          require("neotest").watch.toggle(vim.fn.expand("%"))
        end),
        desc = "Toggle Watch (with save)",
      },
    },
  },
}
