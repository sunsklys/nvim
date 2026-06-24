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
    init = function()
      -- 全局副作用：开启 autoread 后【所有】 buffer 在外部被修改时会自动重载。
      -- opencode.nvim 的 events.reload 依赖此机制接收编辑反馈。
      -- 副作用是：其他场景（如多个编辑器同时改同一文件）也会触发静默重载。
      vim.o.autoread = true
    end,
    config = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        server = {
          start = function()
            require("snacks.terminal").open(opencode_cmd, snacks_terminal_opts)
          end,
        },
      }
    end,
    keys = {
      -- 终端切换（沿用原 <leader>oo 习惯）
      {
        "<leader>oo",
        function()
          require("snacks.terminal").toggle(opencode_cmd, snacks_terminal_opts)
        end,
        mode = { "n" },
        desc = "切换 OpenCode",
      },
      -- 核心交互
      {
        "<leader>oa",
        function()
          require("opencode").ask("@this: ")
        end,
        mode = { "n", "x" },
        desc = "询问 OpenCode (输入框)",
      },
      {
        "<leader>op",
        function()
          require("opencode").select()
        end,
        mode = { "n", "x" },
        desc = "选择预置 prompt",
      },
      -- 内置 prompts 一键触发
      {
        "<leader>oe",
        function()
          require("opencode").prompt("Explain @this and its context")
        end,
        mode = { "n", "x" },
        desc = "解释当前代码",
      },
      {
        "<leader>or",
        function()
          require("opencode").prompt("Review @this for correctness and readability")
        end,
        mode = { "n", "x" },
        desc = "审查当前代码",
      },
      {
        "<leader>of",
        function()
          require("opencode").prompt("Fix @diagnostics")
        end,
        desc = "修复诊断",
      },
      {
        "<leader>ot",
        function()
          require("opencode").prompt("Add tests for @this")
        end,
        mode = { "n", "x" },
        desc = "为当前代码生成测试",
      },
      {
        "<leader>oz",
        function()
          require("opencode").prompt("Optimize @this for performance and readability")
        end,
        mode = { "n", "x" },
        desc = "优化当前代码",
      },
      {
        "<leader>od",
        function()
          require("opencode").prompt("Add comments documenting @this")
        end,
        mode = { "n", "x" },
        desc = "为当前代码添加注释",
      },
      -- Operator + dot-repeat
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
          return require("opencode").operator("@this ") .. "_"
        end,
        mode = "n",
        expr = true,
        desc = "把整行发给 OpenCode",
      },
      -- Session 管理
      {
        "<leader>on",
        function()
          require("opencode").command("session.new")
        end,
        desc = "新建会话",
      },
      {
        "<leader>oS",
        function()
          require("opencode").select()
        end,
        mode = { "n", "x" },
        desc = "选择会话/命令/prompt",
      },
      {
        "<leader>ou",
        function()
          require("opencode").command("session.undo")
        end,
        desc = "撤销上一步",
      },
      {
        "<leader>oR",
        function()
          require("opencode").command("session.redo")
        end,
        desc = "重做",
      },
      {
        "<leader>oc",
        function()
          require("opencode").command("session.compact")
        end,
        desc = "压缩当前会话",
      },
      {
        "<leader>oi",
        function()
          require("opencode").command("session.interrupt")
        end,
        desc = "中断当前会话",
      },
      -- 滚动 OpenCode 输出
      {
        "<S-C-u>",
        function()
          require("opencode").command("session.half.page.up")
        end,
        desc = "向上滚动 OpenCode",
      },
      {
        "<S-C-d>",
        function()
          require("opencode").command("session.half.page.down")
        end,
        desc = "向下滚动 OpenCode",
      },
    },
  },
}
