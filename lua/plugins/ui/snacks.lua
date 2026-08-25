-- snacks.nvim 配置

-- module-local 常量，避免每次重建 patterns table（全部小写：is_secret 对 name:lower() 匹配，大小写不敏感）
local SECRET_PATTERNS = {
  "%.env[%w.]*$", -- .env / .env.local / .envrc
  "^id_[%w]+$", -- SSH 私钥（无扩展名：id_rsa/ed25519/ecdsa/dsa）
  "^id_[%w]+%.pub$", -- SSH 公钥（id_*.pub）
  "/id_[%w]+$", -- 同上但路径上下文（/id_xxx）
  "/id_[%w]+%.pub$", -- 路径上下文 .pub
  "%.pem$", -- *.pem（大小写不敏感后 [pP] 不再需要）
  "%.p12$", -- *.p12 (PKCS12)
  "%.pfx$", -- *.pfx (PKCS12)
  "%.key$", -- *.key
  "%.aws[/\\]", -- .aws/
  "%.ssh[/\\]", -- .ssh/
  "%.kube[/\\]config", -- kubeconfig
  "%.npmrc$", -- npm registry token
  "%.netrc$", -- machine credentials
  "%.pypirc$", -- PyPI credentials
  "%.git%-credentials$", -- git credential store
  "%.tfvars$", -- Terraform 变量（常含云密钥）
  "%.htpasswd$", -- HTTP basic auth
  "^aws[_-]credentials$", -- aws_credentials / aws-credentials
  "%.gnupg[/\\]", -- GPG 私钥环（对齐 opencode.json deny list）
  "%.docker[/\\]config", -- docker registry auth token
  "hosts%.json$", -- GitHub Copilot hosts.json（含真实 token，无特征命名）
}

-- 双层守卫：secret/credential 关键字 + 凭证类扩展名同时命中，避免误伤源码
local CREDENTIAL_EXTS = {
  "%.json$",
  "%.ya?ml$",
  "%.toml$",
  "%.ini$",
  "%.conf$",
  "%.cfg$",
  "%.env$",
  "%.txt$",
}

local function is_secret(name)
  local lower = name:lower()
  for _, pat in ipairs(SECRET_PATTERNS) do
    if lower:match(pat) then
      return true
    end
  end
  if lower:find("secret", 1, true) or lower:find("credential", 1, true) then
    for _, ext in ipairs(CREDENTIAL_EXTS) do
      if lower:match(ext) then
        return true
      end
    end
  end
  return false
end

-- 内容级粗筛：文本命中常见 token 特征（防 grep 结果把硬编码密钥送出去）
local TOKEN_PATTERNS = {
  "sk%-%w", -- OpenAI/Anthropic 风格
  "ghp_%w", -- GitHub PAT
  "gho_%w", -- GitHub OAuth
  "gh[sr]_%w", -- GitHub server/refresh token
  "github_pat_", -- GitHub fine-grained PAT
  "AKIA[%w]", -- AWS Access Key
  "xox[bpars]%-", -- Slack token
  "AIza[%w]", -- Google API key
  "glpat[%w_%-]+", -- GitLab PAT（glpat-...）
  "glsa[%w_%-]+", -- GitLab SCIM token
  "shpat[%w_%-]+", -- Shopify API token（shpat_...）
  "npm_%w", -- npm registry token
  "dapi[%w_%-]+", -- Databricks token（dapi-...）
  "eyJ[%w%-]+%.", -- JWT header（eyJxxx.eyJyyy.sig）
  "-----BEGIN [A-Z ]*PRIVATE KEY-----", -- PEM 私钥块
}

-- 高熵 hex 检测的上下文关键字（双条件防误报：git commit sha 恰为 40 位 hex，常现于 grep 结果）
local CRED_HINTS = {
  "token",
  "secret",
  "password",
  "passwd",
  "api_key",
  "apikey",
  "auth",
  "credential",
  "private",
}

-- 文本内容是否命中 token 特征（item.text 是 grep/lines 结果的匹配行）
local function has_token(text)
  for _, pat in ipairs(TOKEN_PATTERNS) do
    if text:match(pat) then
      return true
    end
  end
  -- 高熵 hex 串（≥40 连续十六进制位，覆盖 sha 型以外的纯 hex 密钥）：
  -- 注意 base64 密钥（如 AWS Secret Key 含 /+）不在覆盖内，靠 TOKEN_PATTERNS 前缀层（AKIA）兜底；
  -- 须同时命中凭证上下文关键字才拦（git sha 不误报，误拦代价=跳过+WARN）
  local lower = text:lower()
  for _, hint in ipairs(CRED_HINTS) do
    if lower:find(hint, 1, true) then
      for hex in text:gmatch("[0-9a-fA-F]+") do
        if #hex >= 40 then
          return true
        end
      end
      break
    end
  end
  return false
end

return {
  {
    "folke/snacks.nvim",
    opts = {
      input = { enabled = true },
      image = { enabled = true, doc = { max_width = 60, max_height = 20 } },
      picker = {
        enabled = true,
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
            -- 列宽按屏宽 15%，min_width 30 给窄屏兜底
            layout = { layout = { width = 0.16, min_width = 30 } },
          },
        },
        actions = {
          ---@param picker snacks.Picker
          -- 在 snacks picker 中按 <a-a> 发送选中项到 OpenCode
          opencode_send = function(picker)
            ---@type snacks.picker.Item[]
            local selected = picker:selected({ fallback = true })
            -- 安全护栏：密钥/凭证文件不发给 AI provider
            local items = vim.tbl_filter(
              function(i)
                return i ~= nil
              end,
              vim.tbl_map(function(item)
                local content = item.file or item.text or ""
                if is_secret(content) then
                  vim.notify("跳过疑似密钥/凭证文件: " .. content, vim.log.levels.WARN)
                  return nil
                end
                -- 内容级粗筛：grep/lines picker 的匹配行里常见 token 前缀直接拦截
                if item.text and item.text ~= "" and has_token(item.text) then
                  vim.notify("跳过含 token 特征的匹配行: " .. content, vim.log.levels.WARN)
                  return nil
                end
                -- pos[2] 是 0-based col，opencode.format 期望 1-based：+1 转换
                local function shift(pos)
                  return pos and { pos[1], pos[2] and pos[2] + 1 or nil } or nil
                end
                local from = shift(item.pos)
                local to = shift(item.end_pos)
                -- pcall 防御：无 file/pos 的 picker item 不让单个项炸掉整批（<a-a> 挂全局所有 picker）
                local ok_fmt, formatted = pcall(require("opencode").format, { path = item.file, from = from, to = to })
                return ok_fmt and (formatted or item.file) or item.file
              end, selected)
            )
            if #items == 0 then
              return vim.notify("没有可发送的项（全部被安全过滤或选中为空）", vim.log.levels.WARN)
            end
            require("opencode").prompt(table.concat(items, ", ") .. " ")
          end,
        },
        win = {
          input = {
            keys = {
              ["<a-a>"] = { "opencode_send", mode = { "n", "i" }, desc = "→ 发送到 OpenCode" },
            },
          },
        },
      },
    },
  },
}
