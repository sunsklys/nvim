-- LazyVim 默认 moon，本仓库显式选 night 与 lazygit/delta 配色一致
-- 已知限制：<leader>ub 背景切换对 tokyonight 无效（upstream bug）
return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      styles = {
        -- sidebars/floats 用 normal 与主编辑区背景统一（tokyonight 默认 dark 偏深）
        sidebars = "normal",
        floats = "normal",
      },
    },
  },
}
