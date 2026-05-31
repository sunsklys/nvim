return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    build = "make BUILD_FROM_SOURCE=true",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-telescope/telescope.nvim",
      "hrsh7th/nvim-cmp",
      "nvim-tree/nvim-web-devicons",
      "zbirenbaum/copilot.lua",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = { file_types = { "Avante" } },
        ft = { "Avante" },
      },
    },
    opts = {
      provider = "opencode",
      providers = {
        opencode = {
          __inherited_from = "openai",
          endpoint = "http://localhost:8080/v1",
          model = "opencode",
          api_key_name = "OPAI_API_KEY",
          api_key = "opencode",
        },
      },
      behaviour = {
        auto_suggestions = false,
        auto_set_keymaps = true,
        support_paste_from_clipboard = true,
      },
      mappings = {
        ask = "<leader>aa",
        edit = "<leader>ae",
        refresh = "<leader>ar",
        diff = {
          ours = "co",
          theirs = "ct",
          both = "cb",
          next = "]x",
          prev = "[x",
        },
      },
      windows = {
        wrap = true,
        width = 40,
        sidebar_header = {
          enabled = true,
        },
      },
    },
  },
}