-- luarocks 路径（magick Lua 绑定 for snacks.image 图片渲染）
package.path = package.path .. ";" .. vim.fn.expand("$HOME/.luarocks/share/lua/5.1/?.lua") .. ";" .. vim.fn.expand("$HOME/.luarocks/share/lua/5.1/?/init.lua")
package.cpath = package.cpath .. ";" .. vim.fn.expand("$HOME/.luarocks/lib/lua/5.1/?.so")

vim.g.lazyvim_eslint_auto_format = false
vim.g.lazyvim_ts_lsp = "vtsls"
-- LazyVim lang.python extra 默认用 pyright；用户偏好 basedpyright（fork，更严格类型检查）
-- LazyVim lang.python extra 内置支持此切换（见 extras/lang/python.lua:9 读取 g 变量，:54-63 按它切 enabled）
vim.g.lazyvim_python_lsp = "basedpyright"

-- opencode.nvim 的 events.reload 依赖 autoread 接收编辑反馈。
-- 副作用：多个编辑器同改一个文件也会触发静默重载（undo 历史可能被打断）。
vim.o.autoread = true

-- 终端标签页显示：项目名/当前文件夹（OSC 0/2，Ghostty/iTerm2/WezTerm 等均支持）
vim.opt.title = true
vim.opt.titlestring = "%{fnamemodify(getcwd(), ':t')}/%{expand('%:h:t')}"

-- 终端字符宽度：ambiwidth 默认就是 "single"，这里显式写出作为文档。
-- 现代 macOS 终端（iTerm2/Ghostty/Kitty/WezTerm/Terminal.app）对 ambiguous-width
-- 字符（含 box-drawing │─┼、全角标点 ，。等）默认按 1 列渲染，与
-- Neovim 默认一致。不要设为 "double"：box-drawing 字符 EAW 分类为 A，
-- 会被当作 2 列宽 → Neovim 与终端宽度认知不一致 → 表格/光标错位。
-- 若全角标点需要按 2 列展示，使用 vim.fn.setcellwidths() 精确指定。
vim.opt.ambiwidth = "single"

-- 光标上下保留上下文行数：自适应窗口高度（大窗口 8 行，窄分屏 3 行）
vim.opt.scrolloff = 4
vim.api.nvim_create_autocmd({ "WinResized", "VimResized", "WinEnter" }, {
  group = vim.api.nvim_create_augroup("AdaptiveScrolloff", { clear = true }),
  callback = function()
    local h = vim.api.nvim_win_get_height(0)
    vim.wo.scrolloff = (h >= 30) and 8 or 3
  end,
})

-- 长行软换行的视觉优化（适用于 markdown 长段落等 wrap=true 场景）
-- 配合 LazyVim markdown extra 的 wrap=true + linebreak=true 生效
-- - breakindent: 延续行与上一行缩进对齐，层次清晰
-- - showbreak: 延续行前缀标识，明确区分“延续”与“新行”
-- - breakat: 中文标点也可作为断行点（默认仅英文标点和空格）
--
-- 长表格超出窗口宽度时：按 <leader>uw 临时切换为 nowrap，
-- 再用 zL/zH/zh/zl 水平滚动查看完整表格（sidescrolloff 默认 8）。
vim.opt.breakindent = true
-- breakat 是 global-only 选项（:help breakat），无法真正 buffer-local。
-- 这里全局设为含中文标点，但实际只影响 wrap=true 的场景（markdown 长段落）；
-- 代码默认 wrap=false 不会走 breakat 逻辑，所以全局设置对代码无可观察影响。
vim.opt.breakat = " \t,.;:!?，。、；：！？"
vim.opt.showbreak = "↳ "
