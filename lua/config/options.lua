-- env 注入（luarocks + LG_CONFIG + GIT_CONFIG），在插件 spec 加载前执行
require("config.env")

vim.g.lazyvim_eslint_auto_format = false
-- LazyVim lang.python extra 内置支持 basedpyright 切换（更严格类型检查）
vim.g.lazyvim_python_lsp = "basedpyright"

-- opencode.nvim events.reload 依赖；副作用：多编辑器同改文件会静默重载
vim.opt.autoread = true

-- 禁用 autowrite 避免 format_on_save 污染 undo 树；auto-save.nvim 用 noautocmd 覆盖数据安全
vim.o.autowrite = false
-- 终端标签页：项目名/当前文件夹（OSC 0/2）
vim.opt.title = true
vim.opt.titlestring = "%{fnamemodify(getcwd(), ':t')}/%{expand('%:h:t')}"

-- 不要设为 "double"：box-drawing 字符 EAW 分类为 A，设 double 会导致表格/光标错位
vim.opt.ambiwidth = "single"

-- 自适应窗口高度：大窗口 8 行，窄分屏 3 行
vim.opt.scrolloff = 3
-- 不用 BufEnter：scrolloff 只依赖窗口高度，切 buffer 不改高度，BufEnter 是冗余触发
vim.api.nvim_create_autocmd({ "WinResized", "VimResized", "WinEnter" }, {
  group = vim.api.nvim_create_augroup("AdaptiveScrolloff", { clear = true }),
  callback = function()
    local h = vim.api.nvim_win_get_height(0)
    vim.wo.scrolloff = (h >= 30) and 8 or 3
  end,
})

-- 长行软换行视觉优化：breakindent 对齐、showbreak 前缀标识、breakat 中文标点断行
vim.opt.breakindent = true
-- breakat 是 global-only，影响 wrap=true 场景（markdown）；代码 wrap=false 不受影响
vim.opt.breakat = " \t,.;:!?，。、；：！？"
vim.opt.showbreak = "↳ "
