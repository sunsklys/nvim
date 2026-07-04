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
| `ai/opencode.lua` | opencode.nvim | AI 对话/编辑/会话全套（`<leader>a*` 命名空间） |
| `coding/blink.lua` | blink.cmp | 补全（signature help 增强） |
| `editor/diffview.lua` | diffview.nvim | Git diff/merge 查看 |
| `editor/quickfix.lua` | nvim-bqf | Quickfix 增强（预览/过滤/标记） |
| `editor/numb.lua` | numb.nvim | 输入 `:数字` 跳转时实时预览目标行（LazyVim 无内置） |
| `go/lsp.lua` | nvim-lspconfig | gopls analyses 增量：shadow（LazyVim 默认不开） + gofumpt 显式声明（LazyVim 默认已开；unusedwrite/nilness/useany LazyVim 已提供，本文件不重复） |
| `go/neotest.lua` | neotest | neotest-golang 参数 |
| `ui/git.lua` | gitsigns.nvim | current_line_blame 增强 |
| `ui/markdown.lua` | render-markdown.nvim + markdown-preview.nvim | buffer 内渲染 + 浏览器预览 |
| `ui/snacks.lua` | snacks.nvim | picker actions（含 opencode 安全过滤） + explorer 显示隐藏文件 |
| `ui/lualine.lua` | lualine.nvim | 状态栏追加 OpenCode 状态图标（idle/busy/error/未连接） |
| `ui/theme.lua` | tokyonight.nvim | 主题（night style） |

### 关键自定义快捷键

| 键 | 作用 | 来源 |
| --- | --- | --- |
| `<leader>at` | 切换 OpenCode 终端（仅 normal mode） | ai/opencode.lua |
| `<leader>aa` | 询问 OpenCode（输入框） | ai/opencode.lua |
| `<leader>am` | 切换 AI 模型（agent.cycle） | ai/opencode.lua |
| `<leader>ape/apr/apf/apt/apz/apd/apE/apI` | OpenCode 内置 prompts（解释/审查/修复/测试/优化/注释/解释诊断/实现） | ai/opencode.lua |
| `<leader>asn` | 新建会话 | ai/opencode.lua |
| `<leader>asS` | 选择会话/命令/prompt | ai/opencode.lua |
| `<leader>asu` | 撤销上一步 | ai/opencode.lua |
| `<leader>asR` | 重做 | ai/opencode.lua |
| `<leader>asc` | 压缩当前会话 | ai/opencode.lua |
| `<leader>asi` | 中断当前会话 | ai/opencode.lua |
| `<leader>asL` | 跳到最新消息 | ai/opencode.lua |
| `<leader>asP` | 分享当前会话 | ai/opencode.lua |
| `<leader>avU` | 向上滚动 OpenCode 输出 | ai/opencode.lua |
| `<leader>avD` | 向下滚动 OpenCode 输出 | ai/opencode.lua |
| `go{motion}` | 把动作范围发给 OpenCode（operator） | ai/opencode.lua |
| `goo` | 把整行发给 OpenCode（operator） | ai/opencode.lua |
| `<leader>ga` | Go 测试/源文件切换 | config/keymaps.lua |
| `<leader>gdw` | 切换 gitsigns 行内词级 diff | config/keymaps.lua |
| `<leader>gdv/gdV/gdH/gdc` | Diffview 工作区对比/文件历史/仓库历史/关闭 | editor/diffview.lua |
| `<leader>cp` | Markdown 浏览器预览 | ui/markdown.lua |
| `<a-a>` | 在 snacks picker 中把选中项发给 OpenCode（含密钥安全过滤） | ui/snacks.lua |

> **命名空间**：OpenCode 键位使用 `<leader>a*` 命名空间（`at`=终端, `aa`=询问, `am`=模型, `ap*`=prompts, `as*`=session, `av*`=视图），与 LazyVim overseer 的 `<leader>o*` 完全分离。`<leader>oo`/`<leader>oa` 保留为过渡别名。`<leader>at` 只在 normal mode 绑定，在 opencode 终端内先按 `<C-\><C-n>` 回到 normal 再按 `<leader>at` 切换（term mode 无 leader timeout 延迟）。

### 自动保存

`lua/config/autocmds.lua` 监听 `InsertLeave + FocusLost` 触发 `silent! update`（保留 undo 历史，跳过 buftype != "" / 只读 / 未命名 / pumvisible 缓冲区）。

不监听 `TextChanged`（避免 normal mode 每次按键触发全文 fsync）。后果：normal mode 编辑（`x`/`dd`/`p` 等）不会立即写盘，需切换插入模式或失焦才保存。崩溃恢复依赖 nvim 自身的 swap/undo 持久化。

### 终端模式退出

不绑定全局 `<Esc>` terminal mapping（避免截获 nested TUI 如 lazygit/fzf/opencode 终端的 Esc）。退出方式：
- `<C-\><C-n>`：通用终端 → normal mode（Vim 原生）
- `<C-/>`：LazyVim 默认终端 toggle
- 在 opencode 终端内：先 `<C-\><C-n>` 再 `<leader>at` 切换

### Git diff 工具分层

本仓库同时启用三个 diff 工具，分工如下：

| 场景 | 工具 | 快捷键 |
| --- | --- | --- |
| 行内词级 diff（当前文件，快速） | gitsigns | `<leader>gdw`（toggle） |
| 跨文件 / 工作区全对比 | diffview | `<leader>gdv` |
| commit/staging/全 repo（含 lazygit side-by-side） | lazygit | `<leader>gg` |
| 文件历史 | diffview | `<leader>gdV`（当前文件）/ `<leader>gdH`（全仓库） |
| merge 冲突三方对比 | diffview | `:DiffviewOpen`（自动检测冲突） |

按 `|` 在 lazygit 内的两档 diff（并排 / 单栏）间切换。

### 有关 extras 选择的说明

- **未启用 `util.octo`**：octo 会强制接管 `<leader>gi/gI/gp/gP`（disable snacks+gh CLI 的默认行为），改为 octo 命令。本仓库选择保留 LazyVim 默认的轻量 snacks+gh CLI 浏览（`<leader>gi` 列 open issues / `<leader>gI` 列全部 / `<leader>gp` 列 open PRs / `<leader>gP` 列全部）。若需 octo 的深度功能（评论/合并 PR），手动 `:Octo` 命令访问需先启用 extra。
- **`editor.overseer` 使用 LazyVim 默认键位**：OpenCode 已迁移到 `<leader>a*` 命名空间，不再与 overseer 的 `<leader>oo/ot` 碰撞。overseer 保留全部 LazyVim 默认键（`<leader>oo=OverseerRun` / `<leader>ot=OverseerTaskAction` / `<leader>ow=OverseerToggle`）。

### Python LSP 切换

[`config/options.lua`](./lua/config/options.lua) 顶部设 `vim.g.lazyvim_python_lsp = "basedpyright"`，让 LazyVim lang.python extra 用 basedpyright 替代默认 pyright（用户偏好，更严格类型检查）。ruff 作为 linter/formatter 由 LazyVim 默认配置。

### 终端兼容性（Ghostty）

本配置在 Ghostty 上开发和测试。以下 Ghostty 特性被利用：

- **True color / 24-bit**：LazyVim 默认 `termguicolors = true`，Ghostty 原生支持
- **Undercurl / underline styles**：Neovim 0.10+ 原生发 SGR 4:0-4:5 序列，Ghostty 原生渲染（诊断下划线）
- **Kitty graphics protocol**：`snacks.image` 已启用，markdown 图片在 Ghostty 内 inline 渲染（不支持的终端优雅降级）
- **Kitty keyboard protocol**：Neovim 0.11+ `keyprotocol = "auto"`（DA1 probe），Ghostty 自动响应。`<C-S-Up>` 与 `<C-Up>` 可区分。验证：`:lua =vim.opt.keyprotocol:get()` 返回 `"auto"`
- **OSC 0/2 标题**：`vim.opt.title = true` + `titlestring`，Ghostty 正常显示项目名/路径
- **`macos-option-as-alt = true`**：Ghostty 配置中需开启此项，`<a-a>` 等 Alt 组合键才能被 Neovim 正确接收
- **Cursor shape（DECSCUSR）**：Neovim 默认模式切换光标，Ghostty 原生支持
- **剪贴板**：本地使用 `pbcopy`/`pbpaste`（macOS 原生）；SSH 远程场景需自行配 OSC 52

### iTerm2 配置（TokyoNight 主题导入）

本仓库根目录的 [`tokyonight_night.itermcolors`](./tokyonight_night.itermcolors) 是从 `tokyonight.nvim/extras/iterm/` 拷贝的 iTerm2 配色预设，让 iTerm2 的 16 色 + Background/Foreground 与 nvim 内部的 tokyonight night 主题完全一致。

> **必要性**：iTerm2 默认 `Background = #000000`（纯黑），而 nvim 内部用 `#1a1b26`（带紫蓝色调）。差值虽小但足以察觉 —— snacks terminal 里跑的 OpenCode / lazygit / zsh 等 TUI 程序的空区域会透出 iTerm2 背景色，看起来与 nvim 主编辑区「分层」。导入此预设后所有 TUI 视觉统一。

#### 导入步骤

1. iTerm2 → Settings → Profiles → 选中你的 Profile（默认 `Default`）
2. `Colors` 标签 → 右下角 `Color Presets...` → `Import...`
3. 选 `~/.config/nvim/tokyonight_night.itermcolors`
4. 再次点 `Color Presets...` → 选 `tokyonight_night` 激活

#### 配套设置（Alt 键）

iTerm2 没有等价的 Ghostty `macos-option-as-alt = true` 单行配置，需手动设置以让 `<a-a>` 等 Alt 组合键被 Neovim 正确接收（`ui/snacks.lua` 的 `<a-a>` 发送到 OpenCode 依赖此设置）：

- Settings → Profiles → Keys → `Left Option key` 改为 `Esc+`
- Settings → Profiles → Keys → `Right Option key` 改为 `Esc+`

#### 已知差异（vs Ghostty）

| 特性 | Ghostty | iTerm2 |
| --- | --- | --- |
| Kitty graphics protocol | ✅ 原生（`snacks.image` 全格式 inline 渲染） | ❌ 不支持（仅 PNG fallback，且需 `magick` rock） |
| Styled underlines | ✅ 原生 | ⚠️ 部分（curly/dotted/dashed 降级为基础下划线） |
| Theme 一行配置 | `theme = TokyoNight Night` | 需 GUI 导入 `.itermcolors`（无 config 文件） |
| True color / 24-bit | ✅ 默认 | ✅ 默认（`termguicolors` 直接生效） |
| OSC 0/2 标题 | ✅ | ✅ |


### 换电脑后的外部依赖

```bash
brew install lazygit git-delta neovim python3 go node imagemagick pkg-config luarocks && luarocks --lua-version 5.1 install magick
```

- `python3` 用于 lang.python extra（basedpyright/ruff/neotest-python 通过 Mason 自动装）
- `go` 用于 lang.go extra（gopls/delve/gofumpt 等通过 Mason 自动装）
- `node` 用于 lang.typescript / lang.vue extras（vtsls/vue-language-server/prettier/eslint 通过 Mason 自动装）
- `lazygit` + `git-delta` 用于 Git 工作流（diff/merge/lazygit 集成）
- `neovim` 0.11.2+（实测 0.12.3，LazyVim v15 强制要求 0.11.2）
- `imagemagick` + `pkg-config` + `luarocks` + `magick` rock：snacks.image 全格式图片渲染（Ghostty Kitty graphics protocol；无 magick 仅 PNG 可用）

### 查看 LazyVim 最新变更

```vim
:LazyNews        " 读 LazyVim NEWS.md（lazyvim.json 的 news 字段记录已读到哪个 commit）
:LazyExtras      “ 管理 LazyVim extras（启用/禁用/查看状态）
:Lazy            “ 插件管理器（更新/同步/清理）
```
