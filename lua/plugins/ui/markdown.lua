-- Markdown 预览与 buffer 内渲染
--
-- 配置原则：只覆盖 LazyVim markdown extra / render-markdown 插件默认没有的字段。
-- 其余（pipe_table.cell、code.sign、heading.width 等）全部依赖默认值，避免冗余。
--
-- 有效覆盖项（4 项）：
--   1. pipe_table.preset = "round"      表格圆角边框（默认 none）
--   2. code.border = "thin"             代码块细边框（默认 hide）
--   3. anti_conceal.above/below = 1     光标上下 1 行不 conceal（避免编辑闪烁）
--   4. win_options.conceallevel = 2     比默认 3 更柔和（保留 cchar 显示）
--
-- wrap 行为：依赖 LazyVim markdown extra 默认（wrap=true + linebreak=true）。
-- 长表格超出窗口时按 <leader>uw 切 nowrap，再用 zL/zH 水平滚动。

return {
  -- render-markdown.nvim：buffer 内渲染
  {
    "MeanderingProgrammer/render-markdown.nvim",
    -- 仅移除 codecompanion ft（未启用该 extra）；保留 LazyVim 默认的 markdown/norg/rmd/org
    ft = { "markdown", "norg", "rmd", "org" },
    opts = function(_, opts)
      -- 表格圆角边框（LazyVim/插件默认 preset="none" 无圆角）
      opts.pipe_table = vim.tbl_deep_extend("force", opts.pipe_table or {}, {
        preset = "round",
      })

      -- 代码块细边框（LazyVim/插件默认 border="hide" 无边框）
      opts.code = vim.tbl_deep_extend("force", opts.code or {}, {
        border = "thin",
      })

      -- anti_conceal 光标上下文（默认 above=below=0，编辑表格时边框会闪烁）
      opts.anti_conceal = vim.tbl_deep_extend("force", opts.anti_conceal or {}, {
        above = 1,
        below = 1,
      })

      -- conceallevel=2（默认=3 更激进，=2 保留 cchar 显示更柔和）
      opts.win_options = vim.tbl_deep_extend("force", opts.win_options or {}, {
        conceallevel = { default = vim.o.conceallevel, rendered = 2 },
      })

      return opts
    end,
  },

  -- markdown-preview.nvim：浏览器实时预览（LazyVim 不包含，看复杂表格/Mermaid 时更直观）
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    ft = { "markdown" },
    keys = {
      {
        "<leader>cp",
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "Markdown Preview (browser)",
      },
    },
    init = function()
      -- auto_close=0：关闭 buffer 时不自动关闭浏览器预览（默认 1 会关）
      vim.g.mkdp_auto_close = 0
      -- 固定端口（默认 8080+随机后3位，重启 nvim 后旧 URL 会 404）
      vim.g.mkdp_port = "8765"
    end,
  },
}
