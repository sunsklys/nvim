-- 自动保存：normal/insert 改动后 debounce 写盘。错误可见（不再 silent! 吞掉）。
-- per-buffer timer：每个 buffer 独立 debounce，避免跨 buffer 切换打断他 buffer 的 save 队列。
-- 数据安全冗余：LazyVim 默认 autowrite=true 在 BufLeave 类命令时也会写，两套机制互补。
local group = vim.api.nvim_create_augroup("autosave", { clear = true })

-- timer 存 Lua 表里：vim.b[buf] 是 nvim_buf_set_var 代理，只能持 typval 可转类型（string/number/list/
-- dict/bool/funcref）；vim.defer_fn 返回的 uv_timer_t 是 userdata，赋给 vim.b[buf]._autosave_timer 会触发
-- E5012 "Couldn't convert lua value"（__newindex 失败）。
local timers = {}
local function should_save(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return false end
  local bo = vim.bo[buf]
  if bo.buftype ~= "" then return false end             -- 跳过终端/help/qf 等特殊 buffer
  if not bo.modified then return false end              -- 没改不动
  if bo.readonly then return false end                 -- 只读不动
  if vim.api.nvim_buf_get_name(buf) == "" then return false end  -- 无名 buffer（[No Name]）
  if vim.fn.pumvisible() == 1 then return false end    -- 补全菜单开着不写（避免补全中误触发）
  return true
end

local function save(buf)
  if not should_save(buf) then return end
  local was_modified = vim.bo[buf].modified
  -- nvim 内置错误 (readonly/swaplock) 不抛 lua error 也不设 v:errmsg, 只静默跳过.
  -- formatter 失败 (conform) 中断 BufWritePre 也不抛 error, 只是 update 没执行.
  -- 用 modified 状态作失败信号; 失败时再抓 exec output 拿原因.
  local ok, r = pcall(vim.api.nvim_buf_call, buf, function()
    return vim.api.nvim_exec2("update", { output = true })
  end)
  if not ok then
    vim.notify("[autosave] " .. tostring(r), vim.log.levels.ERROR)
  elseif was_modified and vim.bo[buf].modified then
    local reason = (r and r.output and r.output ~= "") and r.output or "unknown reason"
    vim.notify("[autosave] write failed: " .. reason, vim.log.levels.WARN)
  end
end

vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "FocusLost" }, {
  group = group,
  callback = function(ev)
    local buf = ev.buf
    -- per-buffer timer：跨 buffer 切换不会互相取消 debounce 队列
    local t = timers[buf]
    if t then t:stop() end
    timers[buf] = vim.defer_fn(function()
      timers[buf] = nil
      save(buf)
    end, 300)
  end,
})

-- buffer 卸载时清掉 timer 槽，避免 stale 引用阻止 uv_timer_t 被 GC
vim.api.nvim_create_autocmd("BufUnload", {
  group = group,
  callback = function(ev)
    local t = timers[ev.buf]
    if t then t:stop() end
    timers[ev.buf] = nil
  end,
})
