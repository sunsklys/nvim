-- persistence.nvim 显式禁用：LazyVim core 默认装但从未使用
-- （迁移自 AstroNvim resession 后未启用过，session 目录为空实证）。
-- 禁用后 <leader>qs/qS/ql/qd 与 dashboard `s` 键优雅消失
-- （snacks dashboard sections.session 用 have_plugin 探测，无此插件返回 nil）。
-- 若将来需要会话管理，优先考虑 persisted.nvim（git branch 隔离，最接近 resession）。
return {
  { "folke/persistence.nvim", enabled = false },
}
