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
          baleia.automatically(args.buf)
        end,
      })

      -- 兜底：lazy 加载时 BufRead autocmd 尚未注册，手动触发
      local cur = vim.api.nvim_buf_get_name(0)
      if cur:match("%.log$") or cur:match("%.out$") then
        baleia.automatically(0)
      end
    end,
  },
}
