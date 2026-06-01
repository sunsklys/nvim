local opencode_opts = { win = { position = "right", width = 0.4 } }

local function send_to_opencode(cmd)
  local term = Snacks.terminal.get("opencode", opencode_opts)
  if not (term and term.buf and vim.b[term.buf].terminal_job_id) then
    return
  end
  if not term:win_valid() then
    term:show()
  end
  vim.defer_fn(function()
    vim.fn.chansend(vim.b[term.buf].terminal_job_id, cmd .. "\n")
  end, 100)
end

return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>oo",
        function()
          local term = Snacks.terminal.toggle("opencode", opencode_opts)
          if term and term.buf then
            local opts = { buffer = term.buf, noremap = true, silent = true }
            vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], opts)
            vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], opts)
          end
        end,
        mode = { "n", "t" },
        desc = "切换 OpenCode",
      },
      {
        "<leader>os",
        function()
          local filepath = vim.fn.expand("%:p")
          if filepath == "" then return end
          local start_line = vim.fn.line("v")
          local end_line = vim.fn.line(".")
          if start_line > end_line then
            start_line, end_line = end_line, start_line
          end
          send_to_opencode(string.format("@file:%s:%d-%d", filepath, start_line, end_line))
        end,
        mode = "v",
        desc = "发送选中行",
      },
      {
        "<leader>of",
        function()
          local filepath = vim.fn.expand("%:p")
          if filepath == "" then return end
          send_to_opencode(string.format("@file:%s:%d", filepath, vim.fn.line(".")))
        end,
        mode = "n",
        desc = "发送当前行",
      },
      {
        "<leader>oh",
        function()
          Snacks.terminal.toggle(nil, { win = { position = "bottom", height = 15 } })
        end,
        mode = { "n", "t" },
        desc = "水平终端",
      },
      {
        "<leader>ov",
        function()
          Snacks.terminal.toggle(nil, { win = { position = "right", width = 0.4 } })
        end,
        mode = { "n", "t" },
        desc = "垂直终端",
      },
    },
  },
}
