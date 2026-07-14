-- luarocks 路径（magick Lua 绑定 for snacks.image 图片渲染）
package.path = package.path .. ";" .. vim.fn.expand("$HOME/.luarocks/share/lua/5.1/?.lua") .. ";" .. vim.fn.expand("$HOME/.luarocks/share/lua/5.1/?/init.lua")
package.cpath = package.cpath .. ";" .. vim.fn.expand("$HOME/.luarocks/lib/lua/5.1/?.so")

-- 确保 snacks.lazygit 能加载本仓库的 lazygit.yml + tokyonight lazygit theme
-- 问题：从 GUI/Spotlight 启动 nvim 时进程不读 ~/.zshrc，LG_CONFIG_FILE 为空，
--       snacks.lazygit 源码（lua/snacks/lazygit.lua:77-115）检测到空则只加载自己生成的
--       theme（os.editPreset/gui.nerdFontsVersion/color），用户 lazygit.yml 完全跳过。
-- 修复：在 nvim 启动早期（options.lua 在所有插件 spec 之前加载）幂等注入 LG_CONFIG_FILE。
--       从 zsh 启动 nvim 时这里已是 no-op（已有路径会被去重）；~/.zshrc 的 export 仍保留
--       以便纯命令行调用 lazygit（不经过 nvim）时也加载本仓库配置。
local function ensure_in_lg_config(path)
  if vim.fn.filereadable(path) ~= 1 then return end
  for p in string.gmatch(vim.env.LG_CONFIG_FILE or "", "([^,]+)") do
    if vim.fs.normalize(p) == vim.fs.normalize(path) then return end -- 已存在，跳过
  end
  local existing = vim.env.LG_CONFIG_FILE or ""
  vim.env.LG_CONFIG_FILE = path .. (existing ~= "" and "," .. existing or "")
end
ensure_in_lg_config(vim.fn.expand("$HOME/.config/nvim/lazygit.yml"))
ensure_in_lg_config(vim.fn.expand("$HOME/.local/share/nvim/lazy/tokyonight.nvim/extras/lazygit/tokyonight_night.yml"))

-- 让从 nvim 启动的 git 命令（含 lazygit 内的 git show）输出中文 Date。
-- lazygit 的 ShowCmdObj (pkg/commands/git_commands/commit.go) 不传 --date 参数，
-- commit 详情 patch 顶部的 Date: 字段由 git 全局 log.date 决定。
-- 不写 ~/.gitconfig（那是用户系统级配置，不跟随 dotfiles 仓库迁移），
-- 改用 git 官方环境变量 API（GIT_CONFIG_COUNT/KEY/VALUE）在 nvim 启动时注入。
-- 范围：nvim 进程及其子进程（lazygit / :!git / nvim 内 fugitive 等）。
-- 幂等：只在 key 未被占用时追加。
local function set_git_config(key, value)
  local count = tonumber(vim.env.GIT_CONFIG_COUNT or "0") or 0
  for i = 0, count - 1 do
    if vim.env["GIT_CONFIG_KEY_" .. i] == key then return end
  end
  vim.env.GIT_CONFIG_COUNT = tostring(count + 1)
  vim.env["GIT_CONFIG_KEY_" .. count] = key
  vim.env["GIT_CONFIG_VALUE_" .. count] = value
end
set_git_config("log.date", "format:%Y年%m月%d日 %H:%M")

vim.g.lazyvim_eslint_auto_format = false
vim.g.lazyvim_ts_lsp = "vtsls"
-- LazyVim lang.python extra 默认用 pyright；用户偏好 basedpyright（fork，更严格类型检查）
-- LazyVim lang.python extra 内置支持此切换（见 extras/lang/python.lua:9 读取 g 变量，:54-63 按它切 enabled）
vim.g.lazyvim_python_lsp = "basedpyright"

-- opencode.nvim 的 events.reload 依赖 autoread 接收编辑反馈。
-- 副作用：多个编辑器同改一个文件也会触发静默重载（undo 历史可能被打断）。
vim.opt.autoread = true

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
vim.opt.scrolloff = 3
vim.api.nvim_create_autocmd({ "WinResized", "VimResized", "WinEnter", "BufEnter" }, {
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
