-- neotest: 跑测试前主动 silent! wall（autowrite=false 后的兜底）
--
-- 背景：neotest 用 jobstart/uv.spawn 跑外部命令（go test / pytest），不触发 nvim 内置
-- autowrite。LazyVim 默认 autowrite=true 时也只在 :!cmd / :make 触发，对 neotest 无效。
-- 我们禁用了 autowrite（参见 lua/config/options.lua），需要 neotest 跑测试前主动 :wall
-- 避免跑测试用的是 buffer 未落盘的旧代码（auto-save 1s debounce 可能晚于测试启动）。
--
-- silent! 兜底 readonly/swaplock 错误（个别 buffer 不能写不应阻止测试运行）。
-- wall 会触发 BufWritePre → LazyVim format_on_save（conform），format 跑是合理的
-- （用户主动触发测试，预期代码已 format）。
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
    -- 覆盖 LazyVim 默认 6 个触发测试运行的键，加 pre-run wall
    -- 不覆盖：ta (attach), ts (summary), to (output), tO (panel), tS (stop) - 不触发新测试
    keys = {
      { "<leader>tt", with_save(function() require("neotest").run.run(vim.fn.expand("%")) end), desc = "Run File (Neotest, with save)" },
      { "<leader>tT", with_save(function() require("neotest").run.run(vim.uv.cwd()) end), desc = "Run All Test Files (with save)" },
      { "<leader>tr", with_save(function() require("neotest").run.run() end), desc = "Run Nearest (with save)" },
      { "<leader>tl", with_save(function() require("neotest").run.run_last() end), desc = "Run Last (with save)" },
      { "<leader>td", with_save(function() require("neotest").run.run({ strategy = "dap" }) end), desc = "Debug Nearest (with save)" },
      { "<leader>tw", with_save(function() require("neotest").watch.toggle(vim.fn.expand("%")) end), desc = "Toggle Watch (with save)" },
    },
  },
}
