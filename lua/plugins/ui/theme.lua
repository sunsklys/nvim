-- LazyVim 默认 style = "moon"；本仓库显式选 night 与 lazygit.yml/delta 配色路径一致。
-- 已知限制：<leader>ub 背景切换对 tokyonight 无效（upstream bug，非配置问题）。
return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      styles = {
        -- sidebars/floats 用 "normal"：与主编辑区背景统一（tokyonight 默认 "dark" 让侧栏/浮窗偏深，与本仓库的 LazyVim 默认背景观感割裂）
        sidebars = "normal",
        floats = "normal",
      },
    },
  },
}
