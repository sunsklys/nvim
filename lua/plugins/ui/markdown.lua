-- Markdown 预览:markdown-preview.nvim(浏览器)+ render-markdown.nvim(buffer 内)

-- 项目级 prettier 配置检测:executable + pcall 双保险(Mason 未加载完时 prettier 不可执行)
local function has_project_prettier_config(filename)
  if vim.fn.executable("prettier") == 0 then
    return false
  end
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
      vim.g.mkdp_auto_close = 0 -- 关 buffer 不关浏览器
      vim.g.mkdp_echo_preview_url = 1 -- 启动时 echo URL 到 :messages
    end,
    -- 覆盖 LazyVim <leader>cp：启动 preview 前动态选可用端口
    -- init 时检测有 race（其他 nvim 可能抢端口），移到 keymap 触发时（server 启动前）检测
    -- libuv TCP connect 探测（与 nc -z 同语义：连接被拒 = 无监听 = 端口可用）：零 spawn 异步化，
    -- 纯 loopback connect 延迟 μs 级；不用 bind 试接去（SO_REUSEADDR 会误判可用性）
    keys = {
      {
        "<leader>cp",
        function()
          local function try(port, cb)
            if port >= 8770 then
              return cb(8770)
            end -- 全占用兜底：越界端口让 mkdp 报错可见
            local sock = vim.uv.new_tcp()
            sock:connect("127.0.0.1", port, function(err)
              sock:close()
              if err then
                return cb(port)
              end -- ECONNREFUSED = 端口可用
              try(port + 1, cb)
            end)
          end
          try(8765, function(port)
            if port >= 8770 then
              vim.notify(
                "端口 8765-8769 均被占用，使用 8770（若启动失败请关闭旧实例）",
                vim.log.levels.WARN
              )
            end
            -- uv 回调是 fast event context，API/cmd 必须 schedule 回主循环安全域
            vim.schedule(function()
              vim.g.mkdp_port = tostring(port)
              vim.cmd("MarkdownPreviewToggle")
            end)
          end)
        end,
        ft = "markdown",
        desc = "Markdown Preview",
      },
    },
    build = function(plugin)
      require("lazy").load({ plugins = { "markdown-preview.nvim" } })
      vim.fn["mkdp#util#install"]()
      -- patch app/routes.js：/^\d+$/ 路由 302 redirect 到 /page/N
      -- 注意：routes.js 由 mkdp#util#install() 下载产物后才存在，patch 必须在 install 之后
      local routes_path = plugin.dir .. "/app/routes.js"
      local f = io.open(routes_path, "r")
      if not f then
        return vim.notify("markdown-preview: app/routes.js 不存在，跳过 patch", vim.log.levels.WARN)
      end
      local content = f:read("*a")
      f:close()
      -- skip-worktree 固化（幂等）：补丁让 git status 永远 dirty，lazy 更新会报 local changes；
      -- 标记后 status 无视该文件。放幂等短路之前：x+I 重装场景补丁已打但标记丢失，build 重跑时在此补标
      vim.fn.system({ "git", "-C", plugin.dir, "update-index", "--skip-worktree", "app/routes.js" })
      -- 幂等短路：替换串末尾保留了查找锚点，重复 build 会叠加中间件，先检测已 patch 标记
      if content:find("patched_short_url", 1, true) then
        return
      end
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
          -- skip-worktree：patch 写入被 lazy update 视为脏文件阻断更新，git 层忽略后畅通；
          -- 上游重构时幂等锚点不命中会 WARN 提示（重装后 build 重新 patch）
          vim.fn.system({ "git", "-C", plugin.dir, "update-index", "--skip-worktree", "app/routes.js" })
          vim.notify("markdown-preview: routes.js patch 已应用（skip-worktree）", vim.log.levels.INFO)
        else
          vim.notify("markdown-preview: routes.js 写入失败，patch 未应用", vim.log.levels.WARN)
        end
      else
        vim.notify(
          "markdown-preview: routes.js 锚点 '// /page/:number' 未命中，上游可能已重构，patch 跳过",
          vim.log.levels.WARN
        )
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
          if ft ~= "markdown" and ft ~= "markdown.mdx" then
            return {}
          end
          if has_project_prettier_config(ctx.filename) then
            return {}
          end -- 项目配置优先
          return { "--print-width", "120", "--prose-wrap", "preserve" }
        end,
      })
      return opts
    end,
  },
}
