require("ichimurawataru.core")
require("ichimurawataru.lazy")
if not vim.g.vscode then
  require("ichimurawataru.lsp")
  require("ichimurawataru.lsp_document_highlight")
end

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = vim.fn.stdpath("config") .. "/**/*.lua",
  callback = function(ev)
    dofile(ev.file)
  end,
})
