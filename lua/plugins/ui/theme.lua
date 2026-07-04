-- LazyVim 默认 style = "moon"；本仓库显式选 night 与 lazygit.yml/delta 配色路径一致。
-- 已知限制：<leader>ub 背景切换对 tokyonight 无效（upstream bug，非配置问题）。
return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      styles = {
        sidebars = "normal",
        floats = "normal",
      },
    },
  },
}
