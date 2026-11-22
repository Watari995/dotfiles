local M = {}

function M.format(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local client = vim.lsp.get_clients({ bufnr = bufnr, name = "gopls" })[1]
  if not client then
    vim.notify("Go format: gopls is not attached", vim.log.levels.WARN)
    return
  end

  local response, err = client:request_sync("textDocument/codeAction", {
    textDocument = { uri = vim.uri_from_bufnr(bufnr) },
    range = { start = { line = 0, character = 0 }, ["end"] = { line = 0, character = 0 } },
    context = { only = { "source.organizeImports" }, diagnostics = {} },
  }, 3000, bufnr)
  if not response or response.err then
    vim.notify(
      "Go import organization failed: " .. vim.inspect(err or (response and response.err)),
      vim.log.levels.WARN
    )
    return
  end
  for _, action in ipairs(response.result or {}) do
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
    end
  end

  local params = vim.api.nvim_buf_call(bufnr, function()
    return vim.lsp.util.make_formatting_params({})
  end)
  local formatted, format_err = client:request_sync("textDocument/formatting", params, 3000, bufnr)
  if not formatted or formatted.err then
    vim.notify(
      "Go formatting failed: " .. vim.inspect(format_err or (formatted and formatted.err)),
      vim.log.levels.WARN
    )
    return
  end
  if formatted.result then
    vim.lsp.util.apply_text_edits(formatted.result, bufnr, client.offset_encoding)
  end
end

return M
