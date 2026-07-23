-- 启动期环境注入：luarocks 路径 + lazygit 配置 + git 中文 Date
-- 在 options.lua 顶部 require，确保所有插件 spec 加载前 env 已就位
-- 分离自原 options.lua，关注点单一化（vim.opt 留 options.lua）

-- ─── luarocks 路径（magick Lua 绑定 for snacks.image 图片渲染） ──────────────
package.path = package.path
  .. ";"
  .. vim.fn.expand("$HOME/.luarocks/share/lua/5.1/?.lua")
  .. ";"
  .. vim.fn.expand("$HOME/.luarocks/share/lua/5.1/?/init.lua")
package.cpath = package.cpath .. ";" .. vim.fn.expand("$HOME/.luarocks/lib/lua/5.1/?.so")

-- ─── LG_CONFIG_FILE 注入：snacks.lazygit 加载本仓库 lazygit.yml + tokyonight theme ──
-- 问题：从 GUI/Spotlight 启动 nvim 时进程不读 ~/.zshrc，LG_CONFIG_FILE 为空，
--       snacks.lazygit 源码（lua/snacks/lazygit.lua:77-115）检测到空则只加载自己生成的
--       theme（os.editPreset/gui.nerdFontsVersion/color），用户 lazygit.yml 完全跳过。
-- 修复：在 nvim 启动早期（options.lua → env.lua 在所有插件 spec 之前加载）幂等注入。
--       从 zsh 启动 nvim 时这里已是 no-op（已有路径会被去重）；~/.zshrc 的 export 仍保留
--       以便纯命令行调用 lazygit（不经过 nvim）时也加载本仓库配置。
local function ensure_in_lg_config(path)
  if vim.fn.filereadable(path) ~= 1 then return end
  for p in string.gmatch(vim.env.LG_CONFIG_FILE or "", "([^,]+)") do
    if vim.fs.normalize(p) == vim.fs.normalize(path) then return end -- 已存在，跳过
  end
  local existing = vim.env.LG_CONFIG_FILE or ""
  vim.env.LG_CONFIG_FILE = (existing ~= "" and existing .. "," .. path or path)
end
ensure_in_lg_config(vim.fn.expand("$HOME/.config/nvim/lazygit.yml"))
ensure_in_lg_config(vim.fn.expand("$HOME/.local/share/nvim/lazy/tokyonight.nvim/extras/lazygit/tokyonight_night.yml"))

-- ─── GIT_CONFIG_* 注入：让从 nvim 启动的 git 命令输出中文 Date ──────────────
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
