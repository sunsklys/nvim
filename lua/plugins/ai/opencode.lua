-- nickjvandyke/opencode.nvim - 社区维护的 OpenCode neovim 集成（被官方 ecosystem 收录）
-- 替代手写 Snacks.terminal 方案，提供：
-- - 自动 reload edit 后的 buffer
-- - 编辑权限请求时弹 diff 视图（da 接受 / dr 拒绝 / dp/do 单 hunk）
-- - 上下文占位符 @this/@buffer/@diagnostics/@quickfix/@marks
-- - 内置 prompts (explain/fix/review/optimize/test/document/implement/diagnostics)
-- - SSE 事件流 (OpencodeEvent:*)

local opencode_cmd = "opencode --port"
local terminal_opts = { win = { position = "right", width = 0.3, enter = false } }
local nx = { "n", "x" }

-- keymap helpers：消除 prompt/command 类 key 的重复样板
local function prompt(lhs, text, desc)
  return { lhs, function() require("opencode").prompt(text) end, mode = nx, desc = desc }
end
local function cmd(lhs, command, desc)
  return { lhs, function() require("opencode").command(command) end, desc = desc }
end

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
            require("snacks.terminal").open(opencode_cmd, terminal_opts)
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
      { "<leader>a", group = "OpenCode" },
      -- OpenCode 键位命名空间：<leader>a*（从 <leader>o* 迁移，释放 overseer 命名空间）

      -- 终端 + 核心交互
      { "<leader>at", function() require("snacks.terminal").toggle(opencode_cmd, terminal_opts) end, mode = "n", desc = "切换 OpenCode" },
      { "<leader>aa", function() require("opencode").ask("@this: ") end, mode = nx, desc = "询问 OpenCode (输入框)" },
      { "<leader>am", function() require("opencode").command("agent.cycle") end, desc = "切换 AI 模型" },

      -- Prompts 子组 <leader>ap*（原 <leader>oe/or/of/ot/oz/od/oE/oI）
      prompt("<leader>ape", "Explain @this and its context", "解释当前代码"),
      prompt("<leader>apr", "Review @this for correctness and readability", "审查当前代码"),
      prompt("<leader>apf", "Fix @diagnostics", "修复诊断"),
      prompt("<leader>apt", "Add tests for @this", "为当前代码生成测试"),
      prompt("<leader>apz", "Optimize @this for performance and readability", "优化当前代码"),
      prompt("<leader>apd", "Add comments documenting @this", "为当前代码添加注释"),
      prompt("<leader>apE", "Explain @diagnostics", "解释诊断信息"),
      prompt("<leader>apI", "Implement @this", "实现当前代码"),

      -- Session 子组 <leader>as*（原 <leader>on/oS/ou/oR/oc/oi/oL/oP）
      cmd("<leader>asn", "session.new", "新建会话"),
      { "<leader>asS", function() require("opencode").select() end, mode = nx, desc = "选择会话/命令/prompt" },
      cmd("<leader>asu", "session.undo", "撤销上一步"),
      cmd("<leader>asR", "session.redo", "重做"),
      cmd("<leader>asc", "session.compact", "压缩当前会话"),
      cmd("<leader>asi", "session.interrupt", "中断当前会话"),
      cmd("<leader>asL", "session.last", "跳到最新消息"),
      cmd("<leader>asP", "session.share", "分享当前会话"),

      -- 视图/滚动子组 <leader>av*（原 <leader>oU/oD）
      cmd("<leader>avU", "session.half.page.up", "向上滚动 OpenCode"),
      cmd("<leader>avD", "session.half.page.down", "向下滚动 OpenCode"),

      -- Operator + dot-repeat（不随命名空间迁移）
      { "go", function() return require("opencode").operator("@this ") end, mode = nx, expr = true, desc = "把范围发给 OpenCode" },
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
