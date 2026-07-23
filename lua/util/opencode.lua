-- OpenCode TUI PTY helpers
-- 抽自 lua/plugins/ai/opencode.lua，与 plugin spec 解耦
-- 通过 nvim_chan_send 直接发字节给 OpenCode 终端的 PTY，绕过 HTTP 和终端键穿透问题

local M = {}

-- OpenCode TUI 滚动键的字节编码（xterm: Ctrl+Alt+X = ESC(0x1b) + Ctrl+X）
M.keys = {
  line_up = "\x1b\x19", -- Ctrl+Alt+Y
  line_down = "\x1b\x05", -- Ctrl+Alt+E
  half_up = "\x1b\x15", -- Ctrl+Alt+U
  half_down = "\x1b\x04", -- Ctrl+Alt+D
  page_up = "\x1b\x02", -- Ctrl+Alt+B
  page_down = "\x1b\x06", -- Ctrl+Alt+F
  first = "\x07", -- Ctrl+G
  last = "\x1b\x07", -- Ctrl+Alt+G
}

-- 查找 OpenCode 终端的 PTY channel
-- 优先用当前 buffer（如果在 opencode 终端内），否则遍历所有 terminal buffer
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

---通过 PTY 直接发送字节给 OpenCode TUI
---@param bytes string
---@return boolean sent 是否成功发送（false = 找不到 OpenCode 终端）
function M.tui_send(bytes)
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

---发送字节，失败时弹 notify（用于 buffer-local 滚动键）
---@param bytes string
function M.tsnd_warn(bytes)
  if not M.tui_send(bytes) then
    notify_no_oc()
  end
end

---构造 PTY 滚动 keymap spec（支持 count：5<leader>avk = 连续上滚 5 行）
---@param lhs string 快捷键
---@param key string M.keys 的 key（如 "line_up"）
---@param desc string 描述
---@return table keymap spec
function M.tscroll(lhs, key, desc)
  return {
    lhs,
    function()
      local n = vim.v.count1
      local bytes = M.keys[key]
      if bytes and not M.tui_send(n == 1 and bytes or bytes:rep(n)) then
        notify_no_oc()
      end
    end,
    desc = desc,
  }
end

return M
