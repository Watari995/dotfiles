return {
  "b0o/incline.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = function()
    local devicons = require("nvim-web-devicons")
    return {
      highlight = {
        groups = {
          InclineNormal = { group = "Normal", default = false },
          InclineNormalNC = { group = "Normal", default = false },
        },
      },
      window = {
        placement = { horizontal = "right", vertical = "bottom" },
        margin = { horizontal = 0, vertical = 0 },
        padding = 2,
      },
      render = function(props)
        local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":.")
        local filename = vim.fn.fnamemodify(path, ":t")
        local dirname = vim.fn.fnamemodify(path, ":h")
        dirname = dirname ~= "." and dirname or nil
        local icon, color = devicons.get_icon_color(filename, nil, { default = true })
        local result = {}
        for _, diagnostic in ipairs({
          { severity = vim.diagnostic.severity.ERROR, label = "󰅚 ", group = "DiagnosticError" },
          { severity = vim.diagnostic.severity.WARN, label = "󰀪 ", group = "DiagnosticWarn" },
          { severity = vim.diagnostic.severity.INFO, label = " ", group = "DiagnosticInfo" },
          { severity = vim.diagnostic.severity.HINT, label = "󰌶 ", group = "DiagnosticHint" },
        }) do
          local count = #vim.diagnostic.get(props.buf, { severity = diagnostic.severity })
          if count > 0 then
            table.insert(result, { diagnostic.label .. count .. " ", group = diagnostic.group })
          end
        end
        if #result > 0 then
          table.insert(result, { "┊ ", group = "Normal" })
        end
        table.insert(result, { (icon or "") .. " ", guifg = color })
        if vim.bo[props.buf].readonly then
          table.insert(result, { " ", group = "Normal" })
        end
        if dirname then
          table.insert(result, { dirname .. "/", group = "Normal" })
        end
        local cursor_line = vim.api.nvim_win_get_cursor(props.win)[1]
        local line_count = vim.api.nvim_buf_line_count(props.buf)
        local progress = math.floor(cursor_line * 100 / line_count)
        table.insert(result, {
          filename,
          group = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity.ERROR }) > 0
              and "DiagnosticError"
            or "Normal",
          gui = props.focused and "bold" or "none",
        })
        table.insert(result, {
          string.format("  %d%%", progress),
          group = "Comment",
        })
        if vim.bo[props.buf].modified then
          table.insert(result, { " ●", group = "DiagnosticWarn" })
        end
        return result
      end,
    }
  end,
}
