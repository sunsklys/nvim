-- Git diff 查看器：独立 tab 页看 diff/log/merge
-- 替代 Gitsigns 的 hunk diff（更全：整 commit/branch/file history）
--
-- merge 冲突时 :DiffviewOpen 自动显示三方 diff（ours/theirs/base）
return {
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose", "DiffviewToggleFiles" },
    keys = {
      -- 进入 diffview（对比当前工作区 vs HEAD）
      { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diffview 工作区对比" },
      -- 查看文件历史（git log 当前文件）
      { "<leader>gV", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview 文件历史" },
      -- 查看整个仓库历史
      { "<leader>gL", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview 仓库历史" },
      -- 关闭 diffview（回到原 buffer）
      { "<leader>gC", "<cmd>DiffviewClose<cr>", desc = "Diffview 关闭" },
    },
    opts = {
      view = {
        -- merge 工具布局：三方 diff（左 ours / 中 base /右 theirs）
        merge_tool = { layout = "diff3" },
        -- 默认 diff 布局：双栏
        default = { layout = "diff2_horizontal" },
      },
      -- 文件面板默认折叠
      hooks = {
        diff_buf_read = function(bufnr)
          -- diffview 的 buffer 不自动换行（保持代码原样）
          vim.opt_local.wrap = false
        end,
      },
    },
  },
}
