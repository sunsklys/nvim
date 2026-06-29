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

## 启用的 LazyVim extras 与自定义插件

### LazyVim extras（29 个，见 [`lazyvim.json`](./lazyvim.json)）

**语言**: lang.go / lang.markdown / lang.typescript / lang.vue / lang.json / lang.yaml / lang.docker / lang.git / lang.python / lang.sql / lang.toml / lang.tailwind

**编辑器**: editor.snacks_explorer / editor.snacks_picker / editor.inc-rename / editor.dial / editor.outline / editor.illuminate / editor.refactoring / editor.overseer

**编码/UI/工具**: coding.mini-surround / coding.yanky / ui.treesitter-context / linting.eslint / dap.core / test.core / formatting.prettier / util.mini-hipatterns / util.rest

### 自定义插件（`lua/plugins/`）

| 路径 | 插件 | 用途 |
| --- | --- | --- |
| `ai/opencode.lua` | opencode.nvim | AI 对话/编辑/会话全套（183 行配置） |
| `coding/blink.lua` | blink.cmp | 补全（signature help 增强） |
| `editor/diffview.lua` | diffview.nvim | Git diff/merge 查看 |
| `editor/quickfix.lua` | nvim-bqf | Quickfix 增强（预览/过滤/标记） |
| `editor/numb.lua` | numb.nvim | 输入 `:数字` 跳转时实时预览目标行（LazyVim 无内置） |
| `go/lsp.lua` | nvim-lspconfig | gopls analyses 增量：shadow（LazyVim 默认不开） + gofumpt 显式声明（LazyVim 默认已开；unusedwrite/nilness/useany LazyVim 已提供，本文件不重复） |
| `go/neotest.lua` | neotest | neotest-golang 参数 |
| `ui/git.lua` | gitsigns.nvim | current_line_blame 增强 |
| `ui/markdown.lua` | render-markdown.nvim + markdown-preview.nvim | buffer 内渲染 + 浏览器预览 |
| `ui/snacks.lua` | snacks.nvim | picker actions（含 opencode 安全过滤） + explorer 显示隐藏文件 |
| `ui/theme.lua` | tokyonight.nvim | 主题（night style） |
| `ui/which-key.lua` | which-key.nvim | helix preset + 全中文 desc |

### 关键自定义快捷键

| 键 | 作用 | 来源 |
| --- | --- | --- |
| `<leader>oo` | 切换 OpenCode 终端 | ai/opencode.lua |
| `<leader>oa` | 询问 OpenCode（输入框） | ai/opencode.lua |
| `<leader>oS` | 选择会话/命令/prompt | ai/opencode.lua |
| `<leader>oe/or/of/ot/oz/od` | OpenCode 内置 prompts（解释/审查/修复/测试/优化/注释） | ai/opencode.lua |
| `<leader>on` | 新建会话 | ai/opencode.lua |
| `<leader>ou` | 撤销上一步 | ai/opencode.lua |
| `<leader>oR` | 重做 | ai/opencode.lua |
| `<leader>oc` | 压缩当前会话 | ai/opencode.lua |
| `<leader>oi` | 中断当前会话 | ai/opencode.lua |
| `<leader>oU` | 向上滚动 OpenCode 输出 | ai/opencode.lua |
| `<leader>oD` | 向下滚动 OpenCode 输出 | ai/opencode.lua |
| `go{motion}` | 把动作范围发给 OpenCode（operator） | ai/opencode.lua |
| `goo` | 把整行发给 OpenCode（operator） | ai/opencode.lua |
| `<leader>ga` | Go 测试/源文件切换 | config/keymaps.lua |
| `<leader>gW` | 切换 gitsigns 行内词级 diff | config/keymaps.lua |
| `<leader>gv/gV/gH/gC` | Diffview 工作区对比/文件历史/仓库历史/关闭 | editor/diffview.lua |
| `<leader>cp` | Markdown 浏览器预览 | ui/markdown.lua |
| `<a-a>` | 在 snacks picker 中把选中项发给 OpenCode | ui/snacks.lua |

> **命名空间注记**：本仓库占用 15+ `<leader>o*` 子键（LazyVim 默认 `<leader>o` 只给 overseer），未来 LazyVim 若新增 `<leader>oi/oc` 等可能需调整。

### 有关 extras 选择的说明

- **未启用 `util.octo`**：octo 会强制接管 `<leader>gi/gI/gp/gP`（disable snacks+gh CLI 的默认行为），改为 octo 命令。本仓库选择保留 LazyVim 默认的轻量 snacks+gh CLI 浏览（`<leader>gi` 列 open issues / `<leader>gI` 列全部 / `<leader>gp` 列 open PRs / `<leader>gP` 列全部）。若需 octo 的深度功能（评论/合并 PR），手动 `:Octo` 命令访问需先启用 extra。
- **`editor.overseer` 已启用但 `<leader>oo/ot` 被覆盖**：LazyVim overseer extra 默认绑 `<leader>oo=OverseerRun` / `<leader>ot=OverseerTaskAction`，但本仓库 `lua/plugins/ai/opencode.lua` 后加载覆盖了这两个键（lazy.nvim 加载顺序：extras 先 → 用户 plugins 后）。结果：opencode 保留 `<leader>oo/ot` 不受影响；overseer 保留 `<leader>ow`（Toggle task list），OverseerRun 通过 `:OverseerRun` 命令访问。

### Python LSP 切换

[`config/options.lua`](./lua/config/options.lua) 顶部设 `vim.g.lazyvim_python_lsp = "basedpyright"`，让 LazyVim lang.python extra 用 basedpyright 替代默认 pyright（用户偏好，更严格类型检查）。ruff 作为 linter/formatter 由 LazyVim 默认配置。

### 换电脑后的外部依赖

```bash
brew install lazygit git-delta neovim python3 go node
```

- `python3` 用于 lang.python extra（basedpyright/ruff/neotest-python 通过 Mason 自动装）
- `go` 用于 lang.go extra（gopls/delve/gofumpt 等通过 Mason 自动装）
- `node` 用于 lang.typescript / lang.vue extras（vtsls/vue-language-server/prettier/eslint 通过 Mason 自动装）
- `lazygit` + `git-delta` 用于 Git 工作流（diff/merge/lazygit 集成）
- `neovim` 0.11.2+（实测 0.12.3，LazyVim v15 强制要求 0.11.2）

### 查看 LazyVim 最新变更

```vim
:LazyNews        " 读 LazyVim NEWS.md（lazyvim.json 的 news 字段记录已读到哪个 commit）
:LazyExtras      “ 管理 LazyVim extras（启用/禁用/查看状态）
:Lazy            “ 插件管理器（更新/同步/清理）
```
