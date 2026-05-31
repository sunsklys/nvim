return {
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup({
        size = function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
        end,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_terminals = false,
        start_in_insert = true,
        persist_size = true,
        close_on_exit = true,
        auto_scroll = true,
      })

      local Terminal = require("toggleterm.terminal").Terminal
      local opencode = Terminal:new({
        cmd = "opencode",
        direction = "vertical",
        close_on_exit = true,
        on_open = function(term)
          vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
          vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-h>", [[<C-\><C-n><C-w>h]], { noremap = true, silent = true })
          vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-l>", [[<C-\><C-n><C-w>l]], { noremap = true, silent = true })
          vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })
        end,
      })

      vim.keymap.set({ "n", "t" }, "<leader>oo", function()
        opencode:toggle()
      end, { desc = "切换 OpenCode" })

      vim.keymap.set("v", "<leader>os", function()
        local filepath = vim.fn.expand("%:p")
        local start_line = vim.fn.line("v")
        local end_line = vim.fn.line(".")
        if start_line > end_line then
          start_line, end_line = end_line, start_line
        end
        local cmd = string.format("@file:%s:%d-%d", filepath, start_line, end_line)
        opencode:open()
        vim.defer_fn(function()
          opencode:send(cmd)
        end, 100)
      end, { desc = "发送选中行" })

      vim.keymap.set("n", "<leader>of", function()
        local filepath = vim.fn.expand("%:p")
        local line = vim.fn.line(".")
        local cmd = string.format("@file:%s:%d", filepath, line)
        opencode:open()
        vim.defer_fn(function()
          opencode:send(cmd)
        end, 100)
      end, { desc = "发送当前行" })

      vim.keymap.set({ "n", "t" }, "<leader>oh", function()
        local horizontal = Terminal:new({ direction = "horizontal" })
        horizontal:toggle()
      end, { desc = "水平终端" })

      vim.keymap.set({ "n", "t" }, "<leader>ov", function()
        local vertical = Terminal:new({ direction = "vertical" })
        vertical:toggle()
      end, { desc = "垂直终端" })
    end,
  },
}