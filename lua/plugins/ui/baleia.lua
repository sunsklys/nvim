-- log 文件 ANSI 颜色解码：*.log/*.out 自动 streaming，:BaleiaColorize 手动
return {
  {
    "m00qek/baleia.nvim",
    name = "baleia",
    event = { "BufReadPost *.log", "BufReadPost *.out", "BufNewFile *.log", "BufNewFile *.out" },
    cmd = "BaleiaColorize",
    config = function()
      local baleia = require("baleia").setup({})
      vim.api.nvim_create_user_command("BaleiaColorize", function()
        baleia.once(vim.api.nvim_get_current_buf())
      end, { desc = "ANSI 颜色解码（当前 buffer）" })
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        group = vim.api.nvim_create_augroup("baleia", { clear = true }),
        pattern = { "*.log", "*.out" },
        callback = function(args)
          -- once 先给存量行上色（automatically 只管后续变更），再挂 streaming
          baleia.once(args.buf)
          baleia.automatically(args.buf)
        end,
      })

      -- 兑底：lazy 加载后会重放 BufRead 事件给上面的 autocmd（once 在那里跑）；
-- 此处不可 once：会先把 ANSI strip 掉，重放的 once 拿到无色文本 → 清空 extmark 且无法重建
      local cur = vim.api.nvim_buf_get_name(0)
      if cur:match("%.log$") or cur:match("%.out$") then
        baleia.automatically(0)
      end
    end,
  },
}
