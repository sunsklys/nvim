-- nickjvandyke/opencode.nvim - OpenCode neovim 集成，PTY 直发见 lua/util/opencode.lua

local oc = require("util.opencode")

local opencode_cmd = "opencode --port"
local terminal_opts = { win = { position = "right", width = 0.3, enter = true } }
local server_opts = { win = { position = "right", width = 0.3, enter = false } }
local nx = { "n", "x" }

local function prompt(lhs, text, desc)
  return { lhs, function() require("opencode").prompt(text) end, mode = nx, desc = desc }
end
local function cmd(lhs, command, desc)
  return { lhs, function() require("opencode").command(command) end, desc = desc }
end

return {
  {
    "nickjvandyke/opencode.nvim",
    -- 不设 version：lazy-lock.json 锁定 commit，防 pre-1.0 tag breaking 升级
    dependencies = { "folke/snacks.nvim" },
    config = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        server = {
          start = function()
            require("snacks.terminal").open(opencode_cmd, server_opts)
          end,
        },
      }

      local last_redraw = 0
      local group = vim.api.nvim_create_augroup("OpenCodeStatus", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "OpencodeEvent:session.status",
        callback = function()
          local now = vim.uv.hrtime() / 1e6
          if now - last_redraw > 200 then
            last_redraw = now
            vim.defer_fn(function() vim.cmd("redrawstatus") end, 0)
          end
        end,
      })

      -- OpenCode 终端 buffer-local 滚动键（按住 K/J 连续翻，无需 leader 前缀）
      local scroll_grp = vim.api.nvim_create_augroup("OpenCodeScroll", { clear = true })
      vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter" }, {
        group = scroll_grp,
        callback = function(args)
          if vim.bo[args.buf].buftype ~= "terminal" then return end
          if vim.b[args.buf].oc_scroll then return end
          local name = vim.api.nvim_buf_get_name(args.buf)
          if not name:match("opencode") then return end
          vim.b[args.buf].oc_scroll = true
          local o = { buffer = args.buf, silent = true, nowait = true }
          vim.keymap.set("n", "K", function() oc.tsnd_warn(oc.keys.line_up) end, o)
          vim.keymap.set("n", "J", function() oc.tsnd_warn(oc.keys.line_down) end, o)
          vim.keymap.set("n", "<C-u>", function() oc.tsnd_warn(oc.keys.half_up) end, o)
          vim.keymap.set("n", "<C-d>", function() oc.tsnd_warn(oc.keys.half_down) end, o)
          vim.keymap.set("n", "<C-b>", function() oc.tsnd_warn(oc.keys.page_up) end, o)
          vim.keymap.set("n", "<C-f>", function() oc.tsnd_warn(oc.keys.page_down) end, o)
        end,
      })
    end,
    keys = {
      { "<leader>a", group = "OpenCode" },
      -- OpenCode 键位命名空间：<leader>a*（从 <leader>o* 迁移，释放 overseer 命名空间）

      { "<leader>at", function() require("snacks.terminal").toggle(opencode_cmd, terminal_opts) end, mode = "n", desc = "切换 OpenCode" },
      { "<leader>aa", function() require("opencode").ask("@this: ") end, mode = nx, desc = "询问 OpenCode (输入框)" },
      { "<leader>am", function() require("opencode").command("agent.cycle") end, desc = "切换 AI 模型" },

      prompt("<leader>ape", "Explain @this and its context", "解释当前代码"),
      prompt("<leader>apr", "Review @this for correctness and readability", "审查当前代码"),
      prompt("<leader>apf", "Fix @diagnostics", "修复诊断"),
      prompt("<leader>apt", "Add tests for @this", "为当前代码生成测试"),
      prompt("<leader>apz", "Optimize @this for performance and readability", "优化当前代码"),
      prompt("<leader>apd", "Add comments documenting @this", "为当前代码添加注释"),
      prompt("<leader>apE", "Explain @diagnostics", "解释诊断信息"),
      prompt("<leader>apI", "Implement @this", "实现当前代码"),

      cmd("<leader>asn", "session.new", "新建会话"),
      { "<leader>asS", function() require("opencode").select() end, mode = nx, desc = "选择会话/命令/prompt" },
      cmd("<leader>asu", "session.undo", "撤销上一步"),
      cmd("<leader>asR", "session.redo", "重做"),
      cmd("<leader>asc", "session.compact", "压缩当前会话"),
      cmd("<leader>asi", "session.interrupt", "中断当前会话"),
      cmd("<leader>asL", "session.last", "跳到最新消息"),
      cmd("<leader>asP", "session.share", "分享当前会话"),

      -- 视图/滚动子组 <leader>av*（PTY 直发按键字节，绕过 HTTP 和终端键穿透）
      -- 支持 count 前缀：10<leader>avk = 连续上滚 10 行
      { "<leader>av", group = "OpenCode 滚动" },
      oc.tscroll("<leader>avk", "line_up", "上滚（count 行）"),
      oc.tscroll("<leader>avj", "line_down", "下滚（count 行）"),
      oc.tscroll("<leader>avu", "half_up", "上滚半页"),
      oc.tscroll("<leader>avd", "half_down", "下滚半页"),
      oc.tscroll("<leader>avU", "page_up", "上翻整页"),
      oc.tscroll("<leader>avD", "page_down", "下翻整页"),
      oc.tscroll("<leader>avg", "first", "跳到顶部"),
      oc.tscroll("<leader>avG", "last", "跳到底部"),

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
