local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local opts = {
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
}

if vim.g.vscode then
  require("lazy").setup({
    { import = "ichimurawataru.plugins.vscode" },
    { import = "ichimurawataru.plugins.surround" },
    { import = "ichimurawataru.plugins.substitute" },
    { import = "ichimurawataru.plugins.treesitter" },
    { import = "ichimurawataru.plugins.nvim-treesitter-text-objects" },
  }, opts)
else
  require("lazy").setup({
    { import = "ichimurawataru.plugins" },
    { import = "ichimurawataru.plugins.lsp" },
  }, opts)
end
