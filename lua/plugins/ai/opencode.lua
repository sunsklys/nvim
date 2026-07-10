-- nickjvandyke/opencode.nvim - 社区维护的 OpenCode neovim 集成（被官方 ecosystem 收录）
-- 替代手写 Snacks.terminal 方案，提供：
-- - 自动 reload edit 后的 buffer
-- - 编辑权限请求时弹 diff 视图（da 接受 / dr 拒绝 / dp/do 单 hunk）
-- - 上下文占位符 @this/@buffer/@diagnostics/@quickfix/@marks
-- - 内置 prompts (explain/fix/review/optimize/test/document/implement/diagnostics)
-- - SSE 事件流 (OpencodeEvent:*)

local opencode_cmd = "opencode --port"
local terminal_opts = { win = { position = "right", width = 0.3, enter = true } }
local server_opts = { win = { position = "right", width = 0.3, enter = false } }
local nx = { "n", "x" }

-- keymap helpers：消除 prompt/command 类 key 的重复样板
local function prompt(lhs, text, desc)
  return { lhs, function() require("opencode").prompt(text) end, mode = nx, desc = desc }
end
local function cmd(lhs, command, desc)
  return { lhs, function() require("opencode").command(command) end, desc = desc }
end
-- 查找 OpenCode 终端的 PTY channel
local function get_oc_chan()
  if vim.bo.buftype == "terminal" and vim.api.nvim_buf_get_name(0):match("opencode") then
    local ch = vim.bo.channel
    if ch and ch > 0 then return ch end
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == "terminal" then
      local name = vim.api.nvim_buf_get_name(buf)
      if name:match("opencode") then
        local ch = vim.bo[buf].channel
        if ch and ch > 0 then return ch end
      end
    end
  end
end

-- OpenCode TUI 滚动键的字节编码（xterm: Ctrl+Alt+X = ESC(0x1b) + Ctrl+X）
local OC_KEYS = {
  line_up   = "\x1b\x19", -- Ctrl+Alt+Y
  line_down = "\x1b\x05", -- Ctrl+Alt+E
  half_up   = "\x1b\x15", -- Ctrl+Alt+U
  half_down = "\x1b\x04", -- Ctrl+Alt+D
  page_up   = "\x1b\x02", -- Ctrl+Alt+B
  page_down = "\x1b\x06", -- Ctrl+Alt+F
  first     = "\x07",     -- Ctrl+G
  last      = "\x1b\x07", -- Ctrl+Alt+G
}

-- 通过 PTY 直接发送字节给 OpenCode TUI（绕过 HTTP 和终端键穿透问题）
local function tui_send(bytes)
  local ch = get_oc_chan()
  if ch then
    vim.api.nvim_chan_send(ch, bytes)
    return true
  end
  return false
end

local function notify_no_oc()
  vim.notify("找不到 OpenCode 终端", vim.log.levels.WARN)
end

-- buffer-local 滚动：发送失败时提示
local function tsnd_warn(bytes)
  if not tui_send(bytes) then
    notify_no_oc()
  end
end

-- PTY 滚动 helper：支持 count（5<leader>avk = 连续上滚 5 行）
local function tscroll(lhs, key, desc)
  return {
    lhs,
    function()
      local n = vim.v.count1
      local bytes = OC_KEYS[key]
      if bytes and not tui_send(n == 1 and bytes or bytes:rep(n)) then
        notify_no_oc()
      end
    end,
    desc = desc,
  }
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
          if vim.b[args.buf].oc_scroll then return end -- 已绑定，跳过
          local name = vim.api.nvim_buf_get_name(args.buf)
          if not name:match("opencode") then return end
          vim.b[args.buf].oc_scroll = true
          local o = { buffer = args.buf, silent = true, nowait = true }
          vim.keymap.set("n", "K", function() tsnd_warn(OC_KEYS.line_up) end, o)
          vim.keymap.set("n", "J", function() tsnd_warn(OC_KEYS.line_down) end, o)
          vim.keymap.set("n", "<C-u>", function() tsnd_warn(OC_KEYS.half_up) end, o)
          vim.keymap.set("n", "<C-d>", function() tsnd_warn(OC_KEYS.half_down) end, o)
          vim.keymap.set("n", "<C-b>", function() tsnd_warn(OC_KEYS.page_up) end, o)
          vim.keymap.set("n", "<C-f>", function() tsnd_warn(OC_KEYS.page_down) end, o)
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

      -- 视图/滚动子组 <leader>av*（PTY 直发按键字节，绕过 HTTP 和终端键穿透）
      -- 支持 count 前缀：10<leader>avk = 连续上滚 10 行
      { "<leader>av", group = "OpenCode 滚动" },
      tscroll("<leader>avk", "line_up", "上滚（count 行）"),
      tscroll("<leader>avj", "line_down", "下滚（count 行）"),
      tscroll("<leader>avu", "half_up", "上滚半页"),
      tscroll("<leader>avd", "half_down", "下滚半页"),
      tscroll("<leader>avU", "page_up", "上翻整页"),
      tscroll("<leader>avD", "page_down", "下翻整页"),
      tscroll("<leader>avg", "first", "跳到顶部"),
      tscroll("<leader>avG", "last", "跳到底部"),

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
