-- log 文件 ANSI 颜色解码
-- 场景：kubectl logs / docker logs / tail -f app.log 重定向到文件后用 nvim 打开，
-- 里面全是 \033[32m 等 ANSI 转义序列，原本显示成乱码。baleia 自动解析并正确上色。
--
-- 使用：
--   *.log / *.out 文件读取时自动启用 streaming 模式（追加日志实时更新）
--   任意 buffer 手动 :BaleiaColorize 一次性解码（适合临时看粘贴的彩色输出）
return {
  {
    "m00qek/baleia.nvim",
    name = "baleia",
    lazy = true,
    cmd = "BaleiaColorize",
    config = function()
      local baleia = require("baleia").setup({})
      -- 手动一次性解码（命令模式调用）
      vim.api.nvim_create_user_command("BaleiaColorize", function()
        baleia:once(vim.api.nvim_get_current_buf())
      end, { desc = "ANSI 颜色解码（当前 buffer）" })
      -- *.log / *.out 自动 streaming 解码（持续追加的日志）
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        group = vim.api.nvim_create_augroup("baleia", { clear = true }),
        pattern = { "*.log", "*.out" },
        callback = function(args)
          baleia:automatically(args.buf)
        end,
      })
    end,
  },
}
