-- Self-heal kulala.nvim's tree-sitter grammar repo.
-- kulala's fetch_grammar() decides init-vs-fetch solely by checking if `.git`
-- exists; if a startup is interrupted between `git init` and `git remote add origin`,
-- the repo ends up with `.git` but no `origin`, and every later start fails with:
--   fatal: 'origin' does not appear to be a git repository
-- This pre-flight hook ensures `origin` exists before kulala.setup runs.
-- No-op on healthy installs; gracefully no-ops if kulala changes its data dir path.
return {
  "mistweaverco/kulala.nvim",
  init = function()
    local path = vim.fn.stdpath("data") .. "/kulala.nvim/tree-sitter-kulala-http"
    if vim.fn.isdirectory(path .. "/.git") ~= 1 then return end
    local remotes = vim.fn.systemlist({ "git", "-C", path, "remote" })
    if vim.v.shell_error ~= 0 then return end
    if not vim.tbl_contains(remotes, "origin") then
      vim.fn.system({
        "git",
        "-C",
        path,
        "remote",
        "add",
        "origin",
        "https://github.com/mistweaverco/tree-sitter-kulala-http",
      })
    end
  end,
}
