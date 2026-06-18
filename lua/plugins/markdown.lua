-- Markdown 预览与 buffer 内渲染
--
-- 你的痛点：buffer 内表格换行错乱。
-- 根因（已读源码 verify）：
--   render-markdown.nvim 默认 pipe_table.cell = "padded"，该模式会按 strdisplaywidth
--   算最大列宽并用虚拟文本填充，源码 lua/render/markdown/table.lua:367-369
--   直接假设“表已被修改为对齐”。中英文混排时这个假设会火封塔。
-- 对策：
--   1) cell = "raw" — 仅替换 | 符号，不对单元格填充（原始列宽不等就不强
--      制 overlay），源码 table.lua:370-377，完全避开宽度计算。
--   2) style = "normal" — 不画表头/表尾边框，轻量化。
--   3) preset = "round" — 仅替换边框字符（不影响列宽判断），保留美观。
--   4) markdown buffer 禁用软换行，长表宁愿水平滚动。

return {
  -- 1) Buffer 内渲染（主战场）
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "Avante", "codecompanion", "copilot-chat" },
    opts = {
      -- 全局开关：进入 markdown 文件自动渲染；用 :RenderMarkdown toggle 切换
      enabled = true,
      -- 强制要求 conceallevel=2，否则报警告
      anti_conceal = { enabled = true },

      -- ⭐ 表格的关键配置 ⭐
      pipe_table = {
        enabled = true,
        -- preset — 边框字符预设，合法值: none / round / double / heavy
        --   仅替换边框字符，不影响列宽计算，可安全使用
        preset = "round",
        -- style — 渲染策略，合法值: full / normal / none
        --   full   = 画表头/表尾边框线（默认）
        --   normal = 不画表头/表尾边框线，轻量（推荐）
        --   none   = 完全不渲染表格
        style = "normal",
        -- cell — 单元格渲染策略，合法值: overlay / raw / padded / trimmed
        --   padded/trimmed = 按 strdisplaywidth 填充到最大列宽 → 中英文
        --     混排时 strdisplaywidth 计算与终端实际渲染一旦不一致即塌方
        --   raw   = 只替换 | 符号，不填充单元格（推荐、最稳）
        --   overlay = 完全覆盖表格，丢失 conceal/高亮
        cell = "raw",
        padding = 0,
        alignment_indicator = "━", -- 默认值，在 raw 模式下几乎不可见
      },

      -- 代码块也顺手调一下，避免分号/竖线和表格混淆
      code = {
        enabled = true,
        sign = false, -- 关掉左侧 sign，节省 signcolumn
        width = "block",
        right_pad = 1,
      },

      -- 标题图标占位过宽时也可能视觉撑断表格行宽
      heading = {
        enabled = true,
        sign = false,
        width = "full",
      },

      -- 防止 wrap 软换行干扰渲染
      win_options = {
        conceallevel = { default = vim.o.conceallevel, rendered = 2 },
        concealcursor = { default = vim.o.concealcursor, rendered = "" },
      },
    },
    config = function(_, opts)
      require("render-markdown").setup(opts)

      -- markdown buffer 禁用软换行：长表格宁可水平滚动也不要错行
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown" },
        callback = function()
          vim.opt_local.wrap = false
          vim.opt_local.linebreak = false
          vim.opt_local.conceallevel = 2
        end,
      })
    end,
  },

  -- 2) 浏览器实时预览（补充手段，看复杂表格/Mermaid 时更直观）
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
        ft = "markdown",
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "Markdown Preview (browser)",
      },
    },
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_theme = "dark"
      -- 用 GitHub 风格 CSS，表格渲染最贴近线上效果
      vim.g.mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = {},
        disable_sync_scroll = 0,
        sync_scroll_type = "middle",
        hide_yaml_meta = 1,
        sequence_diagrams = {},
        flowchart_diagrams = {},
        content_editable = false,
        disable_filename = 0,
      }
    end,
  },
}
