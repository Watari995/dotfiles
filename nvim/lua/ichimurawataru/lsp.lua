-- Suppress noisy INFO from Neovim's LSP file watcher when watched paths don't exist yet.
-- Source: vim/_watch.lua - "Server may send workspace/didChangeWatchedFiles with nonexistent baseUri"
local _orig_notify = vim.notify
vim.notify = function(msg, level, opts)
  if type(msg) == "string" and msg:match("^watch%.watch:") then
    return
  end
  _orig_notify(msg, level, opts)
end

local keymap = vim.keymap -- for conciseness

vim.api.nvim_create_user_command("LspRestart", function()
  local names = {}
  for _, client in ipairs(vim.lsp.get_clients()) do
    names[client.name] = true
    client:stop()
  end

  if vim.tbl_isempty(names) then
    vim.notify("No LSP clients are running", vim.log.levels.INFO)
    return
  end

  vim.defer_fn(function()
    for name in pairs(names) do
      vim.lsp.enable(name, false)
      vim.lsp.enable(name, true)
    end
  end, 200)
end, { desc = "Restart LSP clients" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf, silent = true }

    -- set keybinds
    opts.desc = "Show semantic LSP references"
    keymap.set("n", "gR", function()
      Snacks.picker.lsp_references()
    end, opts)

    opts.desc = "Go to definition (vsplit right)"
    keymap.set("n", "gD", function()
      vim.cmd("vsplit")
      vim.lsp.buf.definition()
    end, opts)

    opts.desc = "Show LSP definition"
    keymap.set("n", "gd", vim.lsp.buf.definition, opts) -- show lsp definition

    opts.desc = "Show LSP implementations"
    keymap.set("n", "gi", function()
      Snacks.picker.lsp_implementations()
    end, opts) -- show lsp implementations

    opts.desc = "Show LSP type definitions"
    keymap.set("n", "gt", function()
      Snacks.picker.lsp_type_definitions()
    end, opts) -- show lsp type definitions

    opts.desc = "See available code actions"
    keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

    opts.desc = "Smart rename"
    keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

    opts.desc = "Show buffer diagnostics"
    keymap.set("n", "<leader>D", function()
      Snacks.picker.diagnostics_buffer()
    end, opts) -- show diagnostics for file

    opts.desc = "Show line diagnostics"
    keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

    opts.desc = "Go to previous diagnostic"
    keymap.set("n", "[d", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, opts) -- jump to previous diagnostic in buffer

    opts.desc = "Go to next diagnostic"
    keymap.set("n", "]d", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, opts) -- jump to next diagnostic in buffer

    opts.desc = "Show documentation for what is under cursor"
    keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor
  end,
})

-- vim.lsp.inlay_hint.enable(true)

local severity = vim.diagnostic.severity

local icons = {
  [severity.ERROR] = vim.fn.nr2char(0xF057) .. " ",
  [severity.WARN] = vim.fn.nr2char(0xF071) .. " ",
  [severity.HINT] = vim.fn.nr2char(0xF0820) .. " ",
  [severity.INFO] = vim.fn.nr2char(0xF05A) .. " ",
}

local sign_names = {
  [severity.ERROR] = "DiagnosticSignError",
  [severity.WARN] = "DiagnosticSignWarn",
  [severity.HINT] = "DiagnosticSignHint",
  [severity.INFO] = "DiagnosticSignInfo",
}
for sev, name in pairs(sign_names) do
  vim.fn.sign_define(name, { text = icons[sev], texthl = name, numhl = "" })
end

vim.diagnostic.config({
  virtual_text = true,
  signs = {
    text = icons,
  },
})
