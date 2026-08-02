-- okuuva/auto-save.nvim: 替代原 lua/config/autocmds.lua 的手写 autosave（删除 60 行）
--
-- 选 fork 而非原版 Pocco81/Auto-save（已停更）的关键理由：
--   1. noautocmd 字段（fork 独有）：save 时拼 ":noautocmd silent! write"，跳过 BufWritePre/Post。
--      彻底隔离 autosave 与 LazyVim format_on_save（conform 在 BufWritePre 跑），
--      解决 undo 树污染：每次 autosave + format 会让 undo 树堆积 [edit, format] 配对，
--      按 u 撤销原始编辑时需先撤销 format，体验断裂。
--      noautocmd=true 后 autosave 只落盘原始内容；用户主动 :w 仍触发 format。
--   2. 内置 :ASToggle 命令 + require("auto-save").toggle() API：临时禁用 autosave 不需改配置
--      （对应"单编辑不灵活"诉求）。
--   3. lockmarks：保护 '' 和 '.' 等跳转标记不被写盘覆盖。
--
-- 错误可见性：noautocmd 路径用 silent! write 会吞 nvim 内置错误（readonly/swaplock）。
-- 用 AutoSaveWritePost user autocmd + modified 状态反推失败，复刻原手写实现的可见性。
--
-- version 不锁：让 lazy-lock.json 的 commit pin 接管（仓库既有约定，参见 coverage.lua）。
local function warn_if_save_failed()
  vim.api.nvim_create_autocmd("User", {
    pattern = "AutoSaveWritePost",
    group = vim.api.nvim_create_augroup("autosave-notify", { clear = true }),
    callback = function(ev)
      local buf = ev.data and ev.data.saved_buffer
      if not buf or not vim.api.nvim_buf_is_valid(buf) then return end
      -- 写完仍是 modified → 写失败（被 silent! 吞掉的 nvim builtin 错误：readonly/swaplock/filename）
      if vim.bo[buf].modified then
        vim.notify(
          "[autosave] write failed for " .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t"),
          vim.log.levels.WARN
        )
      end
    end,
  })
end

return {
  {
    "okuuva/auto-save.nvim",
    event = "BufReadPost", -- 早接管，避免 VeryLazy 之前的 buffer 漏保
    config = function(_, opts)
      require("auto-save").setup(opts)
      warn_if_save_failed()

  -- 用 Snacks.toggle 注册（与 LazyVim <leader>u* 命名空间一致，在 toggle picker 里可见状态）。
  -- 比 keys="<cmd>ASToggle<CR>" 更地道：状态可见、自动 picker。
  -- Snacks 在 VeryLazy 加载，auto-save 用 BufReadPost lazy load 时机早于 Snacks，需延后到 VeryLazy。
  -- 注意：LazyVim 的 on_very_lazy 是内部 API 不公开，这里手写等效逻辑。
  local function on_very_lazy(fn)
    if vim.v.vim_did_enter == 1 then
      vim.schedule(fn)
    else
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy", once = true, callback = fn,
      })
    end
  end
  on_very_lazy(function()
    Snacks.toggle.new({
      name = "Auto Save",
      get = function() return require("auto-save").enabled() end,
      set = function() require("auto-save").toggle() end,
    }):map("<leader>ut")  -- t = toggle 通用前缀；LazyVim <leader>u* 单字母几乎满，t 未占用
  end)
    end,
    opts = {
      enabled = true,
      debounce_delay = 1000,
      noautocmd = true, -- ★ 核心：跳过 BufWritePre format，autosave 只落盘原始内容
      lockmarks = true,
      write_all_buffers = false,
      -- modifiable 检查插件已硬编码在 should_be_saved 里，这里不重复
      -- modified 检查插件内部 save 前会做（defer 期间被改回不会误写）
      condition = function(buf)
        if not vim.api.nvim_buf_is_valid(buf) then return false end
        local bo = vim.bo[buf]
        if bo.buftype ~= "" then return false end                       -- 跳过终端/help/qf
        if bo.readonly then return false end
        if vim.api.nvim_buf_get_name(buf) == "" then return false end   -- [No Name]
        if vim.fn.pumvisible() == 1 then return false end               -- 补全菜单开着不写
        return true
      end,
      trigger_events = {
        immediate_save       = { "BufLeave", "FocusLost", "QuitPre", "VimSuspend" },
        defer_save           = { "InsertLeave", "TextChanged" },
        cancel_deferred_save = { "InsertEnter" },
      },
    },
  },
}
