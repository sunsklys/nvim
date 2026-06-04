return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shfmt",
        "golangci-lint",
        "gomodifytags",
        "impl",
        "delve",
      },
    },
  },
}
