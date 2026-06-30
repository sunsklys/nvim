-- 显式禁用 LazyVim overseer extra 的 `<leader>oo/ot` 默认键位，
-- 让本仓库 opencode.lua 的同名键（OpenCode 终端切换 / 为当前代码生成测试）
-- 不再依赖 lazy.nvim 的"extras 先加载 → 用户 plugins 后加载覆盖"约定。
-- `<leader>ow`（OverseerToggle 任务列表）保留不动 —— opencode.lua 未占用。
-- 见 .omo/plans/lazyvim-audit-hyperplan.md T5 / architect Round 2 M2。
return {
  {
    "stevearc/overseer.nvim",
    keys = {
      { "<leader>oo", false },
      { "<leader>ot", false },
    },
  },
}
