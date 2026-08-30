-- OpenCode TUI PTY helpers
-- 通过 nvim_chan_send 直接发字节给 OpenCode 终端的 PTY

local M = {}

-- OpenCode TUI 滚动键的字节编码（xterm: Ctrl+Alt+X = ESC(0x1b) + Ctrl+X）
M.keys = {
  line_up = "\x1b\x19",
  line_down = "\x1b\x05",
  half_up = "\x1b\x15",
  half_down = "\x1b\x04",
  page_up = "\x1b\x02",
  page_down = "\x1b\x06",
  first = "\x07",
  last = "\x1b\x07",
}

-- 终端 buffer 是否为 opencode TUI
-- name 格式 term://{cwd}//{pid}:{cmd}：提取 cmd 段首词比对 basename，
-- 拒绝 cwd 子串误中（如 ~/.config/opencode 下的 shell、/数字:opencode 形态目录）
-- 与后缀变体（opencode.sh/opencode-remote），并兼容绝对路径启动
---@param name string
---@return boolean
function M.is_oc_name(name)
  local prog = name:match("term://.-//%d+:(%S+)")
  return prog ~= nil and prog:match("[^/]+$") == "opencode"
end

-- channel 是否存活：jobwait 返回 -1 表示仍在运行；进程退出/已释放的 job 一律返回 -3，
-- pcall 仅作 vim.fn 层异常兆底（如同名参数类型错误）
local function chan_alive(ch)
  local ok, res = pcall(vim.fn.jobwait, { ch }, 0)
  return ok and res[1] == -1
end

-- 查找 opencode 终端的 PTY channel（只返回存活实例）
-- 多实例场景（snacks tid 含 cwd，root 切换后可能分裂第二实例）按 bufid 升序
-- 遍历会先撞到已退出的旧实例，死实例直接跳过
local function get_oc_chan()
  if vim.bo.buftype == "terminal" and M.is_oc_name(vim.api.nvim_buf_get_name(0)) then
    local ch = vim.bo.channel
    if ch and ch > 0 and chan_alive(ch) then
      return ch
    end
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buftype == "terminal" then
      local name = vim.api.nvim_buf_get_name(buf)
      if M.is_oc_name(name) then
        local ch = vim.bo[buf].channel
        if ch and ch > 0 and chan_alive(ch) then
          return ch
        end
      end
    end
  end
end

---通过 PTY 直接发送字节
---@param bytes string
---@return boolean sent 是否成功发送（false = 找不到存活终端或进程已退出）
function M.tui_send(bytes)
  local ch = get_oc_chan()
  if ch then
    -- 存活检查与发送之间进程仍可能退出（chan_send 对关闭流抛错），pcall 双保险
    return pcall(vim.api.nvim_chan_send, ch, bytes)
  end
  return false
end

local function notify_no_oc()
  vim.notify("找不到 OpenCode 终端", vim.log.levels.WARN)
end

---发送字节，失败时弹 notify
---@param bytes string
function M.tsnd_warn(bytes)
  if not M.tui_send(bytes) then
    notify_no_oc()
  end
end

---构造 PTY 滚动 keymap spec（支持 count：5<leader>avk = 连续上滚 5 行）
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
