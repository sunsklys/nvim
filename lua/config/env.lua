-- 启动期环境注入：luarocks 路径 + lazygit 配置 + git 中文 Date
-- 在 options.lua 顶部 require，确保所有插件 spec 加载前 env 已就位

-- luarocks 路径（magick Lua 绑定 for snacks.image）
package.path = package.path
  .. ";"
  .. vim.fn.expand("$HOME/.luarocks/share/lua/5.1/?.lua")
  .. ";"
  .. vim.fn.expand("$HOME/.luarocks/share/lua/5.1/?/init.lua")
package.cpath = package.cpath .. ";" .. vim.fn.expand("$HOME/.luarocks/lib/lua/5.1/?.so")

-- 从 GUI/Spotlight 启动不读 ~/.zshrc，此处幂等注入确保 snacks.lazygit 加载用户配置
local function ensure_in_lg_config(path)
  if vim.fn.filereadable(path) ~= 1 then
    return
  end
  for p in string.gmatch(vim.env.LG_CONFIG_FILE or "", "([^,]+)") do
    if vim.fs.normalize(p) == vim.fs.normalize(path) then
      return
    end
  end
  local existing = vim.env.LG_CONFIG_FILE or ""
  vim.env.LG_CONFIG_FILE = (existing ~= "" and existing .. "," .. path or path)
end
ensure_in_lg_config(vim.fn.expand("$HOME/.config/nvim/lazygit.yml"))
ensure_in_lg_config(vim.fn.expand("$HOME/.local/share/nvim/lazy/tokyonight.nvim/extras/lazygit/tokyonight_night.yml"))

-- 不写 ~/.gitconfig（不随 dotfiles 迁移），改用 GIT_CONFIG_* 环境变量注入 git 中文 Date
local function set_git_config(key, value)
  local count = tonumber(vim.env.GIT_CONFIG_COUNT or "0") or 0
  for i = 0, count - 1 do
    if vim.env["GIT_CONFIG_KEY_" .. i] == key then
      return
    end
  end
  vim.env.GIT_CONFIG_COUNT = tostring(count + 1)
  vim.env["GIT_CONFIG_KEY_" .. count] = key
  vim.env["GIT_CONFIG_VALUE_" .. count] = value
end
set_git_config("log.date", "format:%Y年%m月%d日 %H:%M")
