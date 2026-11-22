local opt = vim.opt

-- Allow trusted per-project Neovim configuration via .nvim.lua.
opt.exrc = true

-- Incline shows file information and cursor position; hide the statusline.
opt.laststatus = 0
opt.showtabline = 0

opt.number = true

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces

opt.breakindent = true

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- Built-in spelling; keep the writable dictionary outside the Nix-managed config.
local spell_dir = vim.fn.stdpath("data") .. "/spell"
vim.fn.mkdir(spell_dir, "p")
opt.spell = true
opt.spelllang = { "en", "cjk" }
opt.spelloptions = "camel"
opt.spellcapcheck = ""
opt.spellfile = spell_dir .. "/en.utf-8.add"

opt.cursorline = true

-- Use true-color highlights for the configured theme.
opt.termguicolors = true
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- turn off swapfile
opt.swapfile = false

opt.scrolloff = 10

opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "YankHighlight", timeout = 200 })
  end,
})
