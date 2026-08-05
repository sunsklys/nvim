-- conform.nvim:全局启用 undojoin,把 format change 并入上一个 edit 的 undo block
-- 解决 LazyVim format_on_save 让 redo 链断(format 落 undo 树分支,<C-r> 跳不到 edit 后状态)
-- wrap conform.format 而非 default_format_opts.undojoin(后者走 conform 白名单会被静默丢弃)
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      local conform = require("conform")
      local orig_format = conform.format
      conform.format = function(o, cb)
        return orig_format(vim.tbl_deep_extend("force", o or {}, { undojoin = true }), cb)
      end
      return opts -- 必须返回,否则破坏 lazy.nvim 多 spec opts 累积链
    end,
  },
}
