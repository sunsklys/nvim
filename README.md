# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

## lazygit 配置

本仓库根目录的 [`lazygit.yml`](./lazygit.yml) 是 lazygit 的用户配置，已被纳入 git 跟踪，跟随仓库迁移。

### 加载机制

lazygit 默认在 macOS 上从 `~/Library/Application Support/lazygit/config.yml` 读取配置。为了让配置跟随本 dotfiles 仓库，使用 lazygit 内置的 `LG_CONFIG_FILE` 环境变量重定向：

```zsh
# ~/.zshrc
export LG_CONFIG_FILE="$HOME/.config/nvim/lazygit.yml"
```

### 功能

在 lazygit 中按 <kbd>|</kbd> 在两档 diff 视图间循环切换（需 lazygit 0.62+）：

| 档位 | 用途 |
| --- | --- |
| delta 并排 | 左右对比 old/new（默认主用，需 `brew install git-delta`） |
| delta 单栏 | 窄屏 / 逐行暂存时更紧凑 |

### 换电脑步骤

1. `brew install lazygit git-delta`
2. `git clone <本仓库> ~/.config/nvim`
3. 在 `~/.zshrc` 添加：
   ```zsh
   export LG_CONFIG_FILE="$HOME/.config/nvim/lazygit.yml"
   export EDITOR='nvim'   # 让 lazygit、git commit、crontab -e 等 TUI 都用 nvim 打开
   ```
4. 完事 —— 终端与 LazyVim 内调用的 lazygit 都会自动读取本仓库的配置，
   按 `e` 键会在父 nvim 进程中打开文件（`nvim-remote` 预设）。
