-- 在 LazyVim 默认 lualine 配置基础上追加 OpenCode 状态显示
-- statusline 返回 "图标 + server URL"（󰚩 idle / 󱜙 busy / 󱚡 error / 󱚧 未连接）
-- 由 opencode.lua config 内的 autocmd 监听 OpencodeEvent:session.status 触发 redrawstatus
-- 用 function + cond 包裹：opencode 是 lazy-loaded，未加载时不显示该组件
return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.sections = opts.sections or {}
      opts.sections.lualine_z = opts.sections.lualine_z or {}
      table.insert(opts.sections.lualine_z, {
        function()
          return require("opencode").statusline()
        end,
        cond = function()
          return package.loaded["opencode"] ~= nil
        end,
      })
    end,
  },
}
