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
-- 空 buffer（无文件名）时只显示项目名；目录段用 :. 先转 cwd 相对路径，
-- 避免绝对路径打开时目录段重复项目名（proj/proj）；根目录文件目录段为 "." 时回退纯项目名（避免 proj/.）
vim.opt.titlestring =
  "%{fnamemodify(getcwd(),':t').(empty(expand('%'))?'':(fnamemodify(expand('%'),':.:h:t')=='.'?'':'/'.fnamemodify(expand('%'),':.:h:t')))}"

-- 不要设为 "double"：box-drawing 字符 EAW 分类为 A，设 double 会导致表格/光标错位
vim.opt.ambiwidth = "single"

-- 自适应窗口高度：大窗口 8 行，窄分屏 3 行
vim.opt.scrolloff = 3
-- 不用 BufEnter：scrolloff 只依赖窗口高度，切 buffer 不改高度，BufEnter 是冗余触发
-- VimEnter：启动首屏到首次 WinEnter 之间也立即对齐 8/3，避免首屏 scrolloff 漂移
vim.api.nvim_create_autocmd({ "WinResized", "VimResized", "WinEnter", "VimEnter" }, {
  group = vim.api.nvim_create_augroup("AdaptiveScrolloff", { clear = true }),
  callback = function()
    local h = vim.api.nvim_win_get_height(0)
    vim.wo.scrolloff = (h >= 30) and 8 or 3
  end,
})

-- 长行软换行视觉优化：breakindent 对齐、showbreak 前缀标识
vim.opt.breakindent = true
-- breakat 是 global-only，影响 wrap=true 场景（markdown）；代码 wrap=false 不受影响
-- 中文标点断行不可行：nvim 官方文档明文 breakat "Only works for ASCII characters"，append 无效已删
-- 默认断行字符（!@*-+;:,./?）保持不动，URL/路径整词不甩行
vim.opt.showbreak = "↳ "

-- 禁用四个未用的 builtin provider：消除启动期解释器探测和 health WARNING
-- （Python 调试走 Mason debugpy 的 DAP 通道，不经 python3 provider；folke 本人 dot 同款）
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
