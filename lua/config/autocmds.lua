-- 自动保存：normal/insert 改动后 debounce 写盘。错误可见（不再 silent! 吞掉）。
local group = vim.api.nvim_create_augroup("autosave", { clear = true })
local timer = nil

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
  local ok, err = pcall(vim.api.nvim_buf_call, buf, function() vim.cmd("update") end)
  if not ok then
    vim.notify("[autosave] " .. tostring(err), vim.log.levels.ERROR)
  elseif was_modified and vim.bo[buf].modified then
    local r = vim.api.nvim_exec2("update", { output = true })
    local reason = (r.output and r.output ~= "") and r.output or "unknown reason"
    vim.notify("[autosave] write failed: " .. reason, vim.log.levels.WARN)
  end
end

vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "FocusLost" }, {
  group = group,
  callback = function(ev)
    -- debounce 300ms：连续 normal mode 按键（dd/jjj..）合并为一次写盘
    if timer then timer:stop() end
    timer = vim.defer_fn(function()
      save(ev.buf)
      timer = nil
    end, 300)
  end,
})
