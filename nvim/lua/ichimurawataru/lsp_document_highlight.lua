vim.opt.updatetime = 400

local function apply_highlights()
  local highlight = {
    bg = "#264f78",
  }

  vim.api.nvim_set_hl(0, "LspReferenceText", highlight)
  vim.api.nvim_set_hl(0, "LspReferenceRead", highlight)
  vim.api.nvim_set_hl(0, "LspReferenceWrite", highlight)
end

apply_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("ichimurawataru_lsp_document_highlight_colors", { clear = true }),
  callback = apply_highlights,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("ichimurawataru_lsp_document_highlight", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or not client.server_capabilities.documentHighlightProvider then
      return
    end

    local buffer = args.buf
    local group = vim.api.nvim_create_augroup("ichimurawataru_lsp_document_highlight_" .. buffer, { clear = true })

    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = group,
      buffer = buffer,
      callback = vim.lsp.buf.document_highlight,
    })

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
      group = group,
      buffer = buffer,
      callback = vim.lsp.buf.clear_references,
    })
  end,
})
