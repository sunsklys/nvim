-- Git diff 查看器：独立 tab 看 diff/log/merge 与三方冲突
return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose", "DiffviewToggleFiles" },
    keys = {
      { "<leader>gvv", "<cmd>DiffviewOpen<cr>", desc = "Diffview 工作区对比" },
      { "<leader>gvV", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview 文件历史" },
      { "<leader>gvH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview 仓库历史" },
      { "<leader>gvc", "<cmd>DiffviewClose<cr>", desc = "Diffview 关闭" },
    },
    opts = {
      view = {
        -- merge 工具布局：三方 diff（左 ours / 中 base /右 theirs）
        merge_tool = { layout = "diff3_horizontal" },
      },
      hooks = {
        diff_buf_read = function(bufnr)
          -- diffview 的 buffer 不自动换行（保持代码原样）
          vim.opt_local.wrap = false
        end,
      },
    },
  },
}
