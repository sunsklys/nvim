-- auto-save.nvim: 自动保存, noautocmd write 隔离 format_on_save
-- 错误可见性：AutoSaveWritePost + modified 反推 silent! write 吞掉的错误
local function warn_if_save_failed()
  vim.api.nvim_create_autocmd("User", {
    pattern = "AutoSaveWritePost",
    group = vim.api.nvim_create_augroup("autosave-notify", { clear = true }),
    callback = function(ev)
      local buf = ev.data and ev.data.saved_buffer
      if not buf or not vim.api.nvim_buf_is_valid(buf) then
        return
      end
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
    event = "BufReadPost",
    config = function(_, opts)
      require("auto-save").setup(opts)
      warn_if_save_failed()

      -- Snacks 在 VeryLazy 才加载，auto-save 用 BufReadPost 早于 Snacks，需延后注册 toggle
      local function on_very_lazy(fn)
        if vim.v.vim_did_enter == 1 then
          vim.schedule(fn)
        else
          vim.api.nvim_create_autocmd("User", {
            pattern = "VeryLazy",
            once = true,
            callback = fn,
          })
        end
      end
      on_very_lazy(function()
        Snacks.toggle
          .new({
            name = "Auto Save",
            get = function()
              return require("auto-save").enabled()
            end,
            set = function()
              require("auto-save").toggle()
            end,
          })
          :map("<leader>ue") -- e 避开 treesitter-context 占用的 ut
      end)
    end,
    opts = {
      enabled = true,
      debounce_delay = 1000,
      noautocmd = true, -- ★ 核心：跳过 BufWritePre format，autosave 只落盘原始内容
      lockmarks = true,
      write_all_buffers = false,
      condition = function(buf)
        if not vim.api.nvim_buf_is_valid(buf) then
          return false
        end
        local bo = vim.bo[buf]
        if bo.buftype ~= "" then
          return false
        end
        if bo.readonly then
          return false
        end
        if vim.api.nvim_buf_get_name(buf) == "" then
          return false
        end
        -- 补全菜单开着不写（blink.cmp 自绘菜单不置 pumvisible，改用其 API；blink 未加载时视为无菜单）
        local ok_blink, blink = pcall(require, "blink.cmp")
        if ok_blink and blink.is_visible() then
          return false
        end
        return true
      end,
      trigger_events = {
        immediate_save = { "BufLeave", "FocusLost", "QuitPre", "VimSuspend" },
        defer_save = { "InsertLeave", "TextChanged" },
        cancel_deferred_save = { "InsertEnter" },
      },
    },
  },
}
