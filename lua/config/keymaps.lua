
vim.keymap.set("n", "<leader>ga", function()
  local f = vim.fn.expand("%:p:r")
  local is_test = f:match("_test$") ~= nil
  -- Go 测试命名约定：foo_test.go（external）/ foo_internal_test.go（internal）
  -- 剥离 _test + _internal 后缀得到源文件 basename（修复原贪婪匹配在 _internal_test 上提取出 foo_internal 的 bug）
  local base = f:gsub("_test$", ""):gsub("_internal$", "")
  if is_test then
    local source = base .. ".go"
    if vim.fn.filereadable(source) == 1 then
      vim.cmd.edit(vim.fn.fnameescape(source))
    end
  else
    -- 源文件 → 测试文件：优先找 _test.go，找不到再找 _internal_test.go
    local candidates = { base .. "_test.go", base .. "_internal_test.go" }
    for _, test in ipairs(candidates) do
      if vim.fn.filereadable(test) == 1 then
        vim.cmd.edit(vim.fn.fnameescape(test))
        return
      end
    end
  end
end, { desc = "Go 测试/源文件切换" })

-- gitsigns word_diff toggle（LazyVim 默认未开，与 current_line_blame 互补）
-- 注意：hunk text object `ih` 已是 LazyVim 默认（editor.lua gitsigns on_attach），无需重配
vim.keymap.set("n", "<leader>gdw", ":Gitsigns toggle_word_diff<CR>", { desc = "切换行内词级 diff" })

-- ─── Smart ESC + 终端快速退出键 ─────────────────────────────────────────────
-- 背景：snacks.nvim 默认给所有终端 buffer 设「双击 ESC 才退出 insert」
-- （200ms 内两次），单击会把 <esc> 字符转发给底层 shell → 命令残留+延迟感。
-- 这里按底层 cmd 智能分流：
--   * 普通 shell（<leader>ft）         → 单击 ESC 立即退（覆盖 snacks 默认）
--   * nested TUI（opencode/lazygit/...）→ 保持 snacks 默认（双击退，保护其 ESC）
--   * 任何终端都可用 <C-;> 兜底单击立即退
local nested_tui_patterns = {
  "opencode", "lazygit", "fzf", "sk", "htop", "top", "tig",
  "man", "less", "more", "tmux", "vim", "nvim", "nano", "emacs",  -- 改为程序名精确匹配（见下方 tbl_contains），故显式列出 nvim
}

vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("SmartTermEsc", { clear = true }),
  callback = function(args)
    local buf = args.buf
    -- 用 schedule 等 snacks.terminal 把 b:snacks_terminal 写入
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(buf) then return end
      local info = vim.b[buf].snacks_terminal
      -- 非 snacks.terminal（如 snacks.lazygit 自管的 win）不干预
      if not info then return end
      -- 注：cmd 可能为 nil（LazyVim <leader>ft 默认调 Snacks.terminal.toggle()，cmd=nil 走默认 shell）；
      --      nil/空 cmd 都当普通 shell 处理（不命中 nested_tui_patterns）

      local cmd = info.cmd or ""
      if type(cmd) == "table" then cmd = cmd[1] or "" end
      -- 取程序名（首词 + 剥路径），精确匹配避免 "manager"/"task"/"desktop" 等子串误判
      local first = cmd:match("^%s*(%S+)") or ""
      local prog = first:match("([^/]+)$") or first
      local is_nested = vim.tbl_contains(nested_tui_patterns, prog)

      if not is_nested then
        -- 普通 shell：buffer-local 覆盖 snacks 的双击 ESC 策略
        vim.keymap.set("t", "<esc>", "<C-\\><C-n>", {
          buffer = buf,
          nowait = true,
          desc = "终端退出 insert (smart esc)",
        })
      end
      -- nested TUI 不设 → 继承 snacks 默认 term_normal（双击退出）
    end)
  end,
})

-- 兜底键：任何终端模式单击 <C-;> 立即回 normal（即使 nested TUI 也强制退）
vim.keymap.set("t", "<C-;>", "<C-\\><C-n>", { desc = "终端强制退出 insert mode" })

-- ─── 终端列表 picker：<leader>fl ───────────────────────────────────────
-- 列出所有运行中的 snacks 终端（含数字前缀开的多个实例），选中后 focus。
-- 配合数字前缀：2<leader>ft 开 #2、3<leader>ft 开 #3 …… 这里负责查看/切换。
-- 注：不用 <leader>ftl，避免与 LazyVim 默认 <leader>ft (toggle) 形成前缀冲突，
--      否则 which-key 会在按完 <leader>ft 后等 timeoutlen 才执行（现象：toggle 卡一下）
vim.keymap.set("n", "<leader>fl", function()
  local SnacksTerm = require("snacks.terminal")
  local terms = SnacksTerm.list()
  if #terms == 0 then
    return vim.notify("没有运行中的 snacks 终端（用 <leader>ft 或 2<leader>ft 创建）", vim.log.levels.WARN)
  end

  local items = {} ---@type snacks.picker.finder.Item[]
  for _, win in ipairs(terms) do
    if win:buf_valid() then
      local buf = win.buf
      local info = vim.b[buf].snacks_terminal or {}
      local cmd = info.cmd
      if cmd == nil then cmd = "(shell)" end
      if type(cmd) == "table" then cmd = table.concat(cmd, " ") end
      local title = vim.b[buf].term_title or ""
      local id = tostring(info.id or "?")
      local shown = win:valid() and "shown" or "hidden"
      items[#items + 1] = {
        text = ("#%s %s [%s] %s"):format(id, cmd, shown, title),
        win = win, cmd = cmd, title = title, id = id, shown = shown,
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
      if not item then return end
      vim.schedule(function()
        local win = item.win
        if win and win:buf_valid() then
          win:show()
          win:focus()
          vim.cmd.startinsert()  -- 与 <leader>ft 一致，进终端即 terminal mode
        end
      end)
    end,
  })
end, { desc = "终端列表" })
