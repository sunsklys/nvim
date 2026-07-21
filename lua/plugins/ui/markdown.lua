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

-- prettier 项目配置检测 —— 用于下方 conform.nvim spec 的 prepend_args 分流决策。
-- 复用 LazyVim has_config 的同一方法（LazyVim/.../extras/formatting/prettier.lua:33-35）：
-- 调 `prettier --find-config-path <filename>`，让 prettier 自己向上查找它支持的全部配置形式
-- （.prettierrc.* / prettier.config.* / package.json "prettier" 字段 / .editorconfig 等）。
-- 比手列文件名更准确（100% 覆盖）且零维护（自动跟随 prettier 演进）。
-- 缓存键是 filename：prettier 按文件向上查，同一文件多次 format 命中缓存（首次 ~30-80ms，
-- 之后 ~0ms）。限制：项目新增 .prettierrc 后 nvim 内不会立即生效，需重启 nvim（与 LazyVim 同样限制）。
local has_prettier_config_cache = {}
local function has_project_prettier_config(filename)
  if has_prettier_config_cache[filename] == nil then
    vim.fn.system({ "prettier", "--find-config-path", filename })
    has_prettier_config_cache[filename] = (vim.v.shell_error == 0)
  end
  return has_prettier_config_cache[filename]
end

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

  -- markdown-preview.nvim：LazyVim lang.markdown extra 已含 cmd/build/keys/config，
  -- 这里只覆盖本仓库偏好的 g 变量（端口固定 + 关 buffer 不关浏览器）
  {
    "iamcco/markdown-preview.nvim",
    init = function()
      -- auto_close=0：关闭 buffer 时不自动关闭浏览器预览（默认 1 会关）
      vim.g.mkdp_auto_close = 0
      -- 固定端口（默认 8080+随机后3位，重启 nvim 后旧 URL 会 404）
      vim.g.mkdp_port = "8765"
    end,
  },

  -- conform.nvim：markdown 专属 prettier 调优
  -- LazyVim formatting.prettier extra 已把 markdown / markdown.mdx 加到 prettier 的 formatters_by_ft，
  -- 默认 print-width=80、prose-wrap="preserve"（prettier 自身默认）。这里覆盖两点：
  --   1. prose-wrap="preserve"（显式）—— 防止 prettier 自动重排中文段落。prettier 对 CJK 字符的
  --      display-width 判断不精准（多数按 1 列计，实际占 2 列），prose-wrap="always" 会把中文段落
  --      拆得支离破碎。"preserve" 保留作者手动换行，prettier 只动表格/列表/标题等结构元素。
  --   2. print-width=120 —— 影响范围比直觉窄（prose-wrap=preserve 已禁用 prose reflow）：
  --      实际只对 (a) 内嵌代码块 ```ts 等的格式化列宽、(b) 80-120 列宽度的窄表格是否需要换行
  --      切片，有可见效果；对纯文本段落无影响。现代终端更宽，给内嵌代码留更宽松的列宽。
  -- 显式写出 "preserve" 是为了 flip 回 always 时知道改哪一行。
  --
  -- 实现细节：
  --   - prepend_args 是 function(self, ctx)，按 ctx.buf 的 filetype 分流 —— 仅 markdown 系列加参数，
  --     其他 ft（ts/js/json/yaml 等）继续走 prettier 默认。
  --   - 项目本地有 prettier 配置则让项目配置赢（默认 prettier CLI 会覆盖 config file，这里反向让步）。
  --     检测由文件顶部的 has_project_prettier_config() 完成 —— 调 prettier --find-config-path，
  --     覆盖 prettier 支持的全部形式（.prettierrc.* / prettier.config.* / package.json "prettier"
  --     字段 / .editorconfig），与 LazyVim has_config 同样实现，带 filename 缓存。
  --   - vim.tbl_deep_extend("force", ...) 合并：保留 LazyVim 设置的 condition（has_parser 检测），仅追加字段。
  --   - 表格对齐：prettier 默认就格式化 GFM 表格的列宽与 padding，无需额外参数。
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters = opts.formatters or {}
      opts.formatters.prettier = vim.tbl_deep_extend("force", opts.formatters.prettier or {}, {
        prepend_args = function(_, ctx)
          local ft = vim.bo[ctx.buf].filetype
          if ft ~= "markdown" and ft ~= "markdown.mdx" then
            return {}
          end
          -- 项目本地有 prettier 配置则让项目配置赢（默认 prettier CLI 会覆盖 config file）
          if has_project_prettier_config(ctx.filename) then
            return {}
          end
          return { "--print-width", "120", "--prose-wrap", "preserve" }
        end,
      })
      return opts
    end,
  },
}
