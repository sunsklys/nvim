-- snacks.nvim 配置集中管理
-- 之前散在 lua/plugins/ui/explorer.lua（picker.sources.explorer）和
-- lua/plugins/ai/opencode.lua（input + picker.actions.opencode_send），
-- 合并到本文件提高可发现性。lazy.nvim 会自动合并各处 opts，行为零变化。
return {
  {
    "folke/snacks.nvim",
    opts = {
      input = { enabled = true },
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
              return name:match("%.env[%w.]*$")      -- .env / .env.local
                  or name:match("id_rsa")            -- id_rsa / id_rsa.pub
                  or name:match("%.pem$")            -- *.pem
                  or name:match("%.p12$")            -- *.p12
                  or name:match("%.key$")            -- *.key
                  or name:match("%.aws[/\\]")        -- .aws/
                  or name:match("%.ssh[/\\]")        -- .ssh/
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
              ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
            },
          },
        },
      },
    },
  },
}
