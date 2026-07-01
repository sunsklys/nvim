-- nickjvandyke/opencode.nvim - 社区维护的 OpenCode neovim 集成（被官方 ecosystem 收录）
-- 替代手写 Snacks.terminal 方案，提供：
-- - 自动 reload edit 后的 buffer
-- - 编辑权限请求时弹 diff 视图（da 接受 / dr 拒绝 / dp/do 单 hunk）
-- - 上下文占位符 @this/@buffer/@diagnostics/@quickfix/@marks
-- - 内置 prompts (explain/fix/review/optimize/test/document/implement/diagnostics)
-- - SSE 事件流 (OpencodeEvent:*)

local opencode_cmd = "opencode --port"
local snacks_terminal_opts = {
  win = { position = "right", width = 0.3, enter = false },
}

return {
  {
    "nickjvandyke/opencode.nvim",
    version = "*",
    dependencies = { "folke/snacks.nvim" },
    config = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        server = {
          start = function()
            require("snacks.terminal").open(opencode_cmd, snacks_terminal_opts)
          end,
        },
      }

      local last_redraw = 0
      vim.api.nvim_create_autocmd("User", {
        pattern = "OpencodeEvent:session.status",
        callback = function()
          local now = vim.uv.hrtime() / 1e6
          if now - last_redraw > 200 then
            last_redraw = now
            vim.defer_fn(function() vim.cmd("redrawstatus") end, 0)
          end
        end,
      })
    end,
    keys = {
      -- ============================================================
      -- OpenCode 键位命名空间：<leader>a*
      -- 从 <leader>o* 迁移而来（释放 overseer 命名空间）
      -- <leader>oo / <leader>oa 保留为过渡别名，肌肉记忆稳定后可删除
      -- ============================================================

      -- 终端切换
      {
        "<leader>at",
        function()
          require("snacks.terminal").toggle(opencode_cmd, snacks_terminal_opts)
        end,
        mode = "n",
        desc = "切换 OpenCode",
      },
      -- 过渡别名（原 <leader>oo）
      {
        "<leader>oo",
        function()
          require("snacks.terminal").toggle(opencode_cmd, snacks_terminal_opts)
        end,
        mode = "n",
        desc = "切换 OpenCode（过渡别名 → <leader>at）",
      },

      -- 核心交互
      {
        "<leader>aa",
        function()
          require("opencode").ask("@this: ")
        end,
        mode = { "n", "x" },
        desc = "询问 OpenCode (输入框)",
      },
      -- 过渡别名（原 <leader>oa）
      {
        "<leader>oa",
        function()
          require("opencode").ask("@this: ")
        end,
        mode = { "n", "x" },
        desc = "询问 OpenCode（过渡别名 → <leader>aa）",
      },

      -- Agent / 模型切换
      {
        "<leader>am",
        function()
          require("opencode").command("agent.cycle")
        end,
        desc = "切换 AI 模型",
      },

      -- ============================================================
      -- Prompts 子组 <leader>ap*（原 <leader>oe/or/of/ot/oz/od/oE/oI）
      -- ============================================================
      {
        "<leader>ape",
        function()
          require("opencode").prompt("Explain @this and its context")
        end,
        mode = { "n", "x" },
        desc = "解释当前代码",
      },
      {
        "<leader>apr",
        function()
          require("opencode").prompt("Review @this for correctness and readability")
        end,
        mode = { "n", "x" },
        desc = "审查当前代码",
      },
      {
        "<leader>apf",
        function()
          require("opencode").prompt("Fix @diagnostics")
        end,
        mode = { "n", "x" },
        desc = "修复诊断",
      },
      {
        "<leader>apt",
        function()
          require("opencode").prompt("Add tests for @this")
        end,
        mode = { "n", "x" },
        desc = "为当前代码生成测试",
      },
      {
        "<leader>apz",
        function()
          require("opencode").prompt("Optimize @this for performance and readability")
        end,
        mode = { "n", "x" },
        desc = "优化当前代码",
      },
      {
        "<leader>apd",
        function()
          require("opencode").prompt("Add comments documenting @this")
        end,
        mode = { "n", "x" },
        desc = "为当前代码添加注释",
      },
      {
        "<leader>apE",
        function()
          require("opencode").prompt("Explain @diagnostics")
        end,
        mode = { "n", "x" },
        desc = "解释诊断信息",
      },
      {
        "<leader>apI",
        function()
          require("opencode").prompt("Implement @this")
        end,
        mode = { "n", "x" },
        desc = "实现当前代码",
      },

      -- ============================================================
      -- Session 子组 <leader>as*（原 <leader>on/oS/ou/oR/oc/oi/oL/oP）
      -- ============================================================
      {
        "<leader>asn",
        function()
          require("opencode").command("session.new")
        end,
        desc = "新建会话",
      },
      {
        "<leader>asS",
        function()
          require("opencode").select()
        end,
        mode = { "n", "x" },
        desc = "选择会话/命令/prompt",
      },
      {
        "<leader>asu",
        function()
          require("opencode").command("session.undo")
        end,
        desc = "撤销上一步",
      },
      {
        "<leader>asR",
        function()
          require("opencode").command("session.redo")
        end,
        desc = "重做",
      },
      {
        "<leader>asc",
        function()
          require("opencode").command("session.compact")
        end,
        desc = "压缩当前会话",
      },
      {
        "<leader>asi",
        function()
          require("opencode").command("session.interrupt")
        end,
        desc = "中断当前会话",
      },
      {
        "<leader>asL",
        function()
          require("opencode").command("session.last")
        end,
        desc = "跳到最新消息",
      },
      {
        "<leader>asP",
        function()
          require("opencode").command("session.share")
        end,
        desc = "分享当前会话",
      },

      -- ============================================================
      -- 视图/滚动子组 <leader>av*（原 <leader>oU/oD）
      -- ============================================================
      {
        "<leader>avU",
        function()
          require("opencode").command("session.half.page.up")
        end,
        desc = "向上滚动 OpenCode",
      },
      {
        "<leader>avD",
        function()
          require("opencode").command("session.half.page.down")
        end,
        desc = "向下滚动 OpenCode",
      },

      -- ============================================================
      -- Operator + dot-repeat（不随命名空间迁移）
      -- ============================================================
      {
        "go",
        function()
          return require("opencode").operator("@this ")
        end,
        mode = { "n", "x" },
        expr = true,
        desc = "把范围发给 OpenCode",
      },
      {
        "goo",
        function()
          -- 尾部 "_" 是 Vim 内置行 motion：g@_ 让 operator 立即作用于整行（与 go{motion} 的等待 motion 相对）
          return require("opencode").operator("@this ") .. "_"
        end,
        mode = "n",
        expr = true,
        desc = "把整行发给 OpenCode",
      },
    },
  },
}
