-- Markdown 预览:markdown-preview.nvim(浏览器)+ render-markdown.nvim(buffer 内)

-- 项目级 prettier 配置检测:executable + pcall 双保险(Mason 未加载完时 prettier 不可执行)
local function has_project_prettier_config(filename)
  if vim.fn.executable("prettier") == 0 then return false end
  local ok = pcall(vim.fn.system, { "prettier", "--find-config-path", filename })
  return ok and vim.v.shell_error == 0
end

return {
  -- render-markdown.nvim:覆盖默认 4 项(圆角表格/细代码边框/光标上下文不 conceal/柔和 conceallevel)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "norg", "rmd", "org" },
    opts = function(_, opts)
      opts.pipe_table = vim.tbl_deep_extend("force", opts.pipe_table or {}, { preset = "round" })
      opts.code = vim.tbl_deep_extend("force", opts.code or {}, { border = "thin" })
      opts.anti_conceal = vim.tbl_deep_extend("force", opts.anti_conceal or {}, { above = 1, below = 1 })
      opts.win_options = vim.tbl_deep_extend("force", opts.win_options or {}, {
        conceallevel = { default = vim.o.conceallevel, rendered = 2 },
      })
      return opts
    end,
  },

  -- markdown-preview.nvim:覆盖 build 加 routes.js patch
  -- (修 client JS startSocket 把 URL /page/N 改成 /N 后浏览器刷新 404 的上游 bug)
  -- patch 用 302 redirect /N → /page/N,不能用直接返回 index.html:
  -- client JS componentDidMount 解析 pathname.split('/')[2] 只认 /page/N 格式,
  -- 直接给 /N 返回 index.html 会让 parseFloat(undefined)=NaN,bufnr 变 NaN → URL 变 /NaN。
  {
    "iamcco/markdown-preview.nvim",
    init = function()
      vim.g.mkdp_auto_close = 0  -- 关 buffer 不关浏览器
      vim.g.mkdp_port = "8765"   -- 固定端口(默认随机,重启后旧 URL 失效)
    end,
    build = function(plugin)
      require("lazy").load({ plugins = { "markdown-preview.nvim" } })
      vim.fn["mkdp#util#install"]()
      -- patch routes.js:/^\d+$/ 路由 302 redirect 到 /page/N
      local patched = content:gsub(
        "// /page/:number",
        "// patched_short_url: /N redirect 到 /page/N(client JS 解析依赖 /page/N 路径)\n"
          .. "use((req, res, next) => {\n"
          .. "  if (/^\\/\\d+$/.test(req.asPath)) {\n"
          .. "    res.statusCode = 302\n"
          .. "    res.setHeader('Location', '/page/' + req.asPath.slice(1))\n"
          .. "    return res.end()\n"
          .. "  }\n"
          .. "  next()\n"
          .. "})\n\n"
          .. "// /page/:number",
        1
      )
      if patched ~= content then
        local f2 = io.open(routes_path, "w")
        if f2 then
          f2:write(patched)
          f2:close()
        end
      end
    end,
  },

  -- conform.nvim:markdown 专属 prettier
  -- (prose-wrap=preserve 防 CJK 段落被拆碎,print-width=120 给内嵌代码更宽列宽)
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters = opts.formatters or {}
      opts.formatters.prettier = vim.tbl_deep_extend("force", opts.formatters.prettier or {}, {
        prepend_args = function(_, ctx)
          local ft = vim.bo[ctx.buf].filetype
          if ft ~= "markdown" and ft ~= "markdown.mdx" then return {} end
          if has_project_prettier_config(ctx.filename) then return {} end  -- 项目配置优先
          return { "--print-width", "120", "--prose-wrap", "preserve" }
        end,
      })
      return opts
    end,
  },
}
