vim.keymap.set("n", "<leader>cg", function()
  local f = vim.fn.expand("%:p:r")
  local is_test = f:match("_test$") ~= nil
  -- Go 测试命名约定：剥离 _test / _internal 后缀（修复贪婪匹配 bug）
  local base = f:gsub("_test$", ""):gsub("_internal$", "")
  if is_test then
    local source = base .. ".go"
    if vim.fn.filereadable(source) == 1 then
      vim.cmd.edit(vim.fn.fnameescape(source))
    end
  else
    local candidates = { base .. "_test.go", base .. "_internal_test.go" }
    for _, test in ipairs(candidates) do
      if vim.fn.filereadable(test) == 1 then
        vim.cmd.edit(vim.fn.fnameescape(test))
        return
      end
    end
  end
end, { desc = "Go 测试/源文件切换" })

-- gitsigns word_diff toggle（LazyVim 默认未开；hunk text object ih 已是默认，无需重配）
vim.keymap.set("n", "<leader>ghw", ":Gitsigns toggle_word_diff<CR>", { desc = "切换行内词级 diff" }) -- ghw 属 hunks 命名空间，避开 LazyVim <leader>gd（git_diff leaf）的前缀冲突

-- ─── Smart ESC：snacks 默认双击退，此处按 cmd 智能分流 ─────────────
-- 普通 shell 单击 ESC 立即退，nested TUI（opencode/lazygit 等）保持双击退保护其 ESC
local nested_tui_patterns = {
  "opencode",
  "lazygit",
  "fzf",
  "sk",
  "htop",
  "top",
  "tig",
  "man",
  "less",
  "more",
  "tmux",
  "vim",
  "nvim",
  "nano",
  "emacs", -- 精确匹配，非子串匹配
}

vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("SmartTermEsc", { clear = true }),
  callback = function(args)
    local buf = args.buf
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      local info = vim.b[buf].snacks_terminal
      -- 非 snacks.terminal（如 snacks.lazygit 自管的 win）不干预
      if not info then
        return
      end
      -- cmd 可能为 nil（`<leader>ft` 默认 shell），不命中 nested_tui_patterns

      local cmd = info.cmd or ""
      if type(cmd) == "table" then
        cmd = cmd[1] or ""
      end
      -- 精确匹配程序名，避免 "manager"/"task" 等子串误判
      local first = cmd:match("^%s*(%S+)") or ""
      local prog = first:match("([^/]+)$") or first
      local is_nested = vim.tbl_contains(nested_tui_patterns, prog)

      if not is_nested then
        vim.keymap.set("t", "<esc>", "<C-\\><C-n>", {
          buffer = buf,
          nowait = true,
          desc = "终端退出 insert (smart esc)",
        })
      end
    end)
  end,
})

-- 兜底键：任何终端模式单击 <C-;> 立即回 normal（即使 nested TUI 也强制退）
vim.keymap.set("t", "<C-;>", "<C-\\><C-n>", { desc = "终端强制退出 insert mode" })

-- ─── 终端列表 picker：<leader>fl ────────────────────────────
-- 列举所有运行中终端供选中 focus；不用 <leader>ftl 避免与 <leader>ft 前缀冲突
vim.keymap.set("n", "<leader>fl", function()
  local SnacksTerm = require("snacks.terminal")
  local terms = SnacksTerm.list()
  if #terms == 0 then
    return vim.notify(
      "没有运行中的 snacks 终端（用 <leader>ft 或 2<leader>ft 创建）",
      vim.log.levels.WARN
    )
  end

  local items = {} ---@type snacks.picker.finder.Item[]
  for _, win in ipairs(terms) do
    if win:buf_valid() then
      local buf = win.buf
      local info = vim.b[buf].snacks_terminal or {}
      local cmd = info.cmd
      if cmd == nil then
        cmd = "(shell)"
      end
      if type(cmd) == "table" then
        cmd = table.concat(cmd, " ")
      end
      local title = vim.b[buf].term_title or ""
      local id = tostring(info.id or "?")
      local shown = win:valid() and "shown" or "hidden"
      items[#items + 1] = {
        text = ("#%s %s [%s] %s"):format(id, cmd, shown, title),
        win = win,
        cmd = cmd,
        title = title,
        id = id,
        shown = shown,
      }
    end
  end

  if #items == 0 then
    return vim.notify("所有 snacks 终端 buffer 已失效", vim.log.levels.WARN)
  end

  require("snacks").picker({
    items = items,
    title = "运行中的终端",
    format = function(item, _)
      return {
        { (" #%-2s "):format(item.id), "SnacksPickerBadge" },
        { ("%-20s "):format(item.cmd:sub(1, 20)), "SnacksPickerSpecial" },
        { ("[%s] "):format(item.shown), item.shown == "shown" and "SnacksPickerDir" or "Comment" },
        { item.title, "SnacksPickerComment" },
      }
    end,
    confirm = function(picker, item)
      picker:close()
      if not item then
        return
      end
      vim.schedule(function()
        local win = item.win
        if win and win:buf_valid() then
          win:show()
          win:focus()
          vim.cmd.startinsert() -- 进终端即 terminal mode
        end
      end)
    end,
  })
end, { desc = "终端列表" })
