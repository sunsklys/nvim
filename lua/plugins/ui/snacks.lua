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
              -- 1. 无歧义路径/扩展名模式（直接拦截）
              if name:match("%.env[%w.]*$") then return true end       -- .env / .env.local / .envrc
              if name:match("id_rsa") then return true end             -- id_rsa / id_rsa.pub
              if name:match("%.[pP]em$") then return true end          -- *.pem / *.Pem
              if name:match("%.p12$") then return true end             -- *.p12
              if name:match("%.pfx$") then return true end             -- *.pfx (PKCS12, 新增)
              if name:match("%.key$") then return true end             -- *.key
              if name:match("%.aws[/\\]") then return true end         -- .aws/
              if name:match("%.ssh[/\\]") then return true end         -- .ssh/
              if name:match("%.kube[/\\]config") then return true end  -- kubeconfig (新增)

              -- 2. secret/credential 关键字 + 凭证类扩展名
              --    凭证扩展名白名单 vs 源码扩展名（.go/.py/.ts/.rs/.java/.vue...）
              --    双层守卫：关键字 + 凭证扩展同时命中才拦截，避免误伤 secret.go 等源码
              local has_credential_ext = name:match("%.json$")
                                      or name:match("%.ya?ml$")
                                      or name:match("%.toml$")
                                      or name:match("%.ini$")
                                      or name:match("%.conf$")
                                      or name:match("%.cfg$")
                                      or name:match("%.env$")
                                      or name:match("%.txt$")
              if (name:match("[Ss]ecret") or name:match("[Cc]redential")) and has_credential_ext then
                return true
              end

              -- 3. 无扩展名的标准凭证文件名（按需补充）
              if name:match("^aws[_-]credentials$") then return true end  -- aws_credentials / aws-credentials

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
