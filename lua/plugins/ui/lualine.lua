-- 在 LazyVim 默认 lualine 基础上追加 OpenCode 状态显示
-- 用 cond 包裹懒加载，opencode 未加载时不显示
return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.sections = opts.sections or {}
      opts.sections.lualine_z = opts.sections.lualine_z or {}
      table.insert(opts.sections.lualine_z, {
        function()
          local s = require("opencode").statusline()
          s = s:gsub("https?://%S+", "")
          return (s:gsub("^%s+", ""):gsub("%s+$", ""))
        end,
        cond = function()
          return package.loaded["opencode"] ~= nil
        end,
      })
    end,
  },
}
