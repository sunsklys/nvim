-- overseer.nvim 使用 LazyVim extra 默认键位。
-- opencode.nvim 已迁移到 <leader>a* 命名空间，不再与 overseer 的 <leader>oo/ot 碰撞。
-- 历史：曾用显式 keys=false 禁用 overseer 默认键，随 B3 Option I 迁移已删除。
return {
  {
    "stevearc/overseer.nvim",
  },
}
