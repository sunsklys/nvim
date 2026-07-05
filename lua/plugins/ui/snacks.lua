-- snacks.nvim 配置集中管理
-- 之前散在 lua/plugins/ui/explorer.lua（picker.sources.explorer）和
-- lua/plugins/ai/opencode.lua（input + picker.actions.opencode_send），
-- 合并到本文件提高可发现性。lazy.nvim 会自动合并各处 opts，行为零变化。
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
            hidden = true, -- 显示隐藏文件（dotfiles）
            ignored = true, -- 显示 .gitignore 忽略的文件
          },
        },
        actions = {
          ---@param picker snacks.Picker
          -- 在任意 snacks picker（find_files/grep/explorer 等）中按 <a-a>，
          -- 把选中项（文件/文本）作为 prompt 发送给 opencode
          opencode_send = function(picker)
            ---@type snacks.picker.Item[]
            local selected = picker:selected({ fallback = true })
            -- 安全护栏：疑似密钥/凭证文件不发给 AI provider（避免 .env/*.pem/id_rsa 一键泄漏）
            -- Lua 模式不支持 | 或运算，逐个 match
            local function is_secret(name)
              -- 模式表：命中即拦截（无歧义路径/扩展名）
              local secret_patterns = {
                "%.env[%w.]*$",        -- .env / .env.local / .envrc
                "id_rsa",              -- id_rsa / id_rsa.pub
                "%.[pP]em$",           -- *.pem
                "%.p12$",              -- *.p12 (PKCS12)
                "%.pfx$",              -- *.pfx (PKCS12)
                "%.key$",              -- *.key
                "%.aws[/\\]",          -- .aws/
                "%.ssh[/\\]",          -- .ssh/
                "%.kube[/\\]config",   -- kubeconfig
                "%.npmrc$",            -- npm registry token
                "%.netrc$",            -- machine credentials
                "%.pypirc$",           -- PyPI credentials
                "%.git%-credentials$", -- git credential store
                "%.tfvars$",           -- Terraform 变量（常含云密钥）
                "%.htpasswd$",         -- HTTP basic auth
                "^aws[_-]credentials$",-- aws_credentials / aws-credentials
              }
              for _, pat in ipairs(secret_patterns) do
                if name:match(pat) then return true end
              end

              -- 双层守卫：secret/credential 关键字 + 凭证类扩展名同时命中
              -- （避免误伤 secret.go 等源码）
              if name:match("[Ss]ecret") or name:match("[Cc]redential") then
                local credential_exts = {
                  "%.json$", "%.ya?ml$", "%.toml$", "%.ini$",
                  "%.conf$", "%.cfg$", "%.env$", "%.txt$",
                }
                for _, ext in ipairs(credential_exts) do
                  if name:match(ext) then return true end
                end
              end

              return false
            end
            local items = vim.tbl_filter(function(i) return i ~= nil end, vim.tbl_map(function(item)
              local content = item.file or item.text or ""
              if is_secret(content) then
                vim.notify("跳过疑似密钥/凭证文件: " .. content, vim.log.levels.WARN)
                return nil
              end
              return item.file
                  and require("opencode").format({ path = item.file, from = item.pos, to = item.end_pos })
                or item.text
            end, selected))
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
      cheatsheet = {
        enabled = true,
      },
    },
  },
}
