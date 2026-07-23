-- 自定义 health check：验证本 dotfiles 仓库的外部依赖是否就绪
-- 用法：:checkhealth nvim-config
local M = {}

function M.check()
  -- ─── Neovim 版本 ──────────────────────────────────────────────
  vim.health.start("nvim-config: Neovim")
  local v = vim.version()
  if v >= vim.version({ 0, 11, 2 }) then
    vim.health.ok(("Neovim %d.%d.%d"):format(v.major, v.minor, v.patch))
  else
    vim.health.error(
      ("Neovim %d.%d.%d 过旧"):format(v.major, v.minor, v.patch),
      "LazyVim v15+ 要求 nvim 0.11.2+，建议 brew install neovim"
    )
  end

  -- ─── 外部命令依赖 ─────────────────────────────────────────────
  vim.health.start("nvim-config: 外部命令")
  local required_cmds = {
    { cmd = "lazygit", desc = "Git TUI", install = "brew install lazygit" },
    { cmd = "delta", desc = "Git diff pager（delta 并排 diff）", install = "brew install git-delta" },
    { cmd = "prettier", desc = "Markdown/JS/TS formatter（Mason 通常会装）", install = ":MasonInstall prettier" },
    { cmd = "rg", desc = "ripgrep（snacks_picker grep 搜索）", install = "brew install ripgrep" },
    { cmd = { "fd", "fdfind" }, desc = "fd（snacks_picker find_files）", install = "brew install fd" },
    { cmd = "node", desc = "Node.js（vtsls/prettier/eslint via Mason）", install = "brew install node" },
    { cmd = "python3", desc = "Python 3（basedpyright/ruff/neotest-python via Mason）", install = "brew install python3" },
    { cmd = "go", desc = "Go（gopls/delve/gofumpt via Mason）", install = "brew install go" },
  }
  for _, item in ipairs(required_cmds) do
    local found = false
    if type(item.cmd) == "table" then
      for _, c in ipairs(item.cmd) do
        if vim.fn.executable(c) == 1 then
          found = true
          break
        end
      end
    else
      found = vim.fn.executable(item.cmd) == 1
    end
    if found then
      vim.health.ok(item.desc .. " ✓")
    else
      vim.health.warn(item.desc .. " 未安装", item.install)
    end
  end

  -- ─── Lua rocks（snacks.image 全格式渲染） ────────────────────
  vim.health.start("nvim-config: Lua rocks")
  local ok_magick = pcall(require, "magick")
  if ok_magick then
    vim.health.ok("magick rock 已安装（snacks.image 全格式图片渲染）")
  else
    vim.health.warn(
      "magick rock 未安装",
      "brew install imagemagick pkg-config luarocks && luarocks --lua-version 5.1 install magick"
    )
  end

  -- ─── 环境变量 ────────────────────────────────────────────────
  vim.health.start("nvim-config: 环境变量")
  local lg = vim.env.LG_CONFIG_FILE or ""
  if lg:match("lazygit%.yml") then
    vim.health.ok("LG_CONFIG_FILE 包含本仓库 lazygit.yml")
  else
    vim.health.warn(
      "LG_CONFIG_FILE 未注入本仓库 lazygit.yml",
      "options.lua 的 env.lua 已在 nvim 内自动注入；命令行 lazygit 需 ~/.zshrc 配置 LG_CONFIG_FILE"
    )
  end
  if vim.env.GIT_CONFIG_COUNT and tonumber(vim.env.GIT_CONFIG_COUNT) > 0 then
    vim.health.ok("GIT_CONFIG_COUNT=" .. vim.env.GIT_CONFIG_COUNT .. "（中文 Date 已注入）")
  else
    vim.health.warn("GIT_CONFIG_COUNT 未设置", "检查 lua/config/env.lua 是否正常加载")
  end

  -- ─── ripgrep / fd 用户级忽略配置（dotfiles 外部依赖） ────────
  vim.health.start("nvim-config: 用户级搜索工具配置")
  local rg_config = vim.fn.expand("~/.config/ripgrep/config")
  if vim.fn.filereadable(rg_config) == 1 then
    vim.health.ok("~/.config/ripgrep/config 存在")
  else
    vim.health.warn(
      "~/.config/ripgrep/config 缺失（ripgrep 不会自动忽略 node_modules/.git 等）",
      "见 README.md ripgrep + fd 全局忽略 段落"
    )
  end
  local fd_ignore = vim.fn.expand("~/.config/fd/ignore")
  if vim.fn.filereadable(fd_ignore) == 1 then
    vim.health.ok("~/.config/fd/ignore 存在")
  else
    vim.health.warn(
      "~/.config/fd/ignore 缺失（fd 不会同步忽略）",
      "见 README.md ripgrep + fd 全局忽略 段落"
    )
  end
end

return M
