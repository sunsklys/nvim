-- snacks.nvim 配置

-- module-local 常量，避免每次重建 patterns table
local SECRET_PATTERNS = {
  "%.env[%w.]*$", -- .env / .env.local / .envrc
  "^id_[%w]+$", -- SSH 私钥（无扩展名：id_rsa/ed25519/ecdsa/dsa）
  "^id_[%w]+%.pub$", -- SSH 公钥（id_*.pub）
  "/id_[%w]+$", -- 同上但路径上下文（/id_xxx）
  "/id_[%w]+%.pub$", -- 路径上下文 .pub
  "%.[pP]em$", -- *.pem
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
  for _, pat in ipairs(SECRET_PATTERNS) do
    if name:match(pat) then
      return true
    end
  end
  if name:match("[Ss]ecret") or name:match("[Cc]redential") then
    for _, ext in ipairs(CREDENTIAL_EXTS) do
      if name:match(ext) then
        return true
      end
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
                -- pos[2] 是 0-based col，opencode.format 期望 1-based：+1 转换
                local function shift(pos) return pos and { pos[1], pos[2] and pos[2] + 1 or nil } or nil end
                local from = shift(item.pos)
                local to = shift(item.end_pos)
                return require("opencode").format({ path = item.file, from = from, to = to }) or item.file
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
