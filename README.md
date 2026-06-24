# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

## lazygit 配置

本仓库根目录的 [`lazygit.yml`](./lazygit.yml) 是 lazygit 的用户配置，已被纳入 git 跟踪，跟随仓库迁移。

### 加载机制

lazygit 默认在 macOS 上从 `~/Library/Application Support/lazygit/config.yml` 读取配置。为了跟随本 dotfiles 仓库 + 复用 LazyVim 的 tokyonight 主题，用 lazygit 内置的 `LG_CONFIG_FILE` 环境变量加载**两个**配置文件（逗号分隔，后者覆盖前者的同名字段）：

```zsh
# ~/.zshrc
export LG_CONFIG_FILE="$HOME/.config/nvim/lazygit.yml,$HOME/.local/share/nvim/lazy/tokyonight.nvim/extras/lazygit/tokyonight_night.yml"
```

- 第 1 个：本仓库的 `lazygit.yml` —— pager、editPreset、sidePanelWidth、nerdFontsVersion
- 第 2 个：`tokyonight.nvim` 提供的 lazygit 主题（边框、选中行等颜色，与 LazyVim 视觉一致）
- 后者路径在 LazyVim 首启后由 lazy.nvim 自动下载，无需手工干预

命令行 `git diff` 也走 delta + tokyonight 配色：需在 `~/.gitconfig` 设置 `core.pager = delta` 激活 delta，再通过 `[include]` 引入 `tokyonight.nvim/extras/delta/tokyonight_night.gitconfig`（后者仅含 plus/minus 颜色样式，不激活 delta 不生效）。
lazygit 内部的 diff 不受影响 —— 它由 `lazygit.yml` 里的 `git.pagers` 直接驱动，不读 `~/.gitconfig`。

### 功能

在 lazygit 中按 <kbd>|</kbd> 在两档 diff 视图间循环切换（需 lazygit 0.62+）：

| 档位 | 用途 |
| --- | --- |
| delta 并排 | 左右对比 old/new（默认主用，需 `brew install git-delta`） |
| delta 单栏 | 窄屏 / 逐行暂存时更紧凑 |

### 换电脑步骤

1. `brew install lazygit git-delta`
2. `git clone <本仓库> ~/.config/nvim`
3. 首次启动 nvim —— LazyVim 会自动下载 tokyonight.nvim 等插件到 `~/.local/share/nvim/lazy/`
4. 在 `~/.zshrc` 添加：
   ```zsh
   export LG_CONFIG_FILE="$HOME/.config/nvim/lazygit.yml,$HOME/.local/share/nvim/lazy/tokyonight.nvim/extras/lazygit/tokyonight_night.yml"
   export EDITOR='nvim'   # 让 lazygit、git commit、crontab -e 等 TUI 都用 nvim 打开
   ```
5. 在 `~/.gitconfig` 添加：
   ```ini
   [include]
       path = ~/.local/share/nvim/lazy/tokyonight.nvim/extras/delta/tokyonight_night.gitconfig
   [core]
       pager = delta                     # 激活 delta，否则上面的 include 颜色不生效
   [interactive]
       diffFilter = delta --color-only   # 让 git add -p / git checkout -p 等交互命令也走 delta
   [delta]
       navigate = true                   # n / N 在 diff 块之间跳转
   ```
6. 完事 —— lazygit 以 tokyonight 主题渲染、并排 diff、按 `|` 切换单栏、`e` 键在父 nvim 打开文件；命令行 `git diff` 也走 delta + tokyonight 配色（`n`/`N` 跳 diff 块）
