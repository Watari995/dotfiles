return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status") -- to configure lazy pending updates count

    local colors = {
      blue = "#65D1FF",
      green = "#3EFFDC",
      violet = "#FF61EF",
      yellow = "#FFDA7B",
      red = "#FF4A4A",
      orange = "#FF9E64",
      fg = "#c3ccdc",
      bg = "#112638",
      inactive_bg = "#2c3043",
    }

    local my_lualine_theme = {
      normal = {
        a = { bg = colors.blue, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      insert = {
        a = { bg = colors.green, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      visual = {
        a = { bg = colors.violet, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      command = {
        a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      replace = {
        a = { bg = colors.red, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      terminal = {
        a = { bg = colors.orange, fg = colors.bg, gui = "bold" },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      inactive = {
        a = { bg = colors.inactive_bg, fg = colors.fg, gui = "bold" },
        b = { bg = colors.inactive_bg, fg = colors.fg },
        c = { bg = colors.inactive_bg, fg = colors.fg },
      },
    }

    -- configure lualine with modified theme
    lualine.setup({
      options = {
        theme = my_lualine_theme,
      },
      sections = {
        lualine_c = {},
        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = "#ff9e64" },
          },
          { "encoding" },
          { "fileformat", symbols = { unix = "" } },
          { "filetype" },
        },
      },
    })

    local symbol_cache = {}
    local update_winbar

    local function stl_escape(value)
      local escaped = tostring(value):gsub("%%", "%%%%")
      return escaped
    end

    local function position_in_range(position, range)
      local start = range.start
      local finish = range["end"]

      if position.line < start.line or position.line > finish.line then
        return false
      end

      if position.line == start.line and position.character < start.character then
        return false
      end

      if position.line == finish.line and position.character > finish.character then
        return false
      end

      return true
    end

    local function symbol_range(symbol)
      return symbol.range or symbol.location and symbol.location.range
    end

    local function symbol_children(symbol)
      return symbol.children or {}
    end

    local function current_symbol_path(symbols)
      if not symbols then
        return {}
      end

      local position = {
        line = vim.api.nvim_win_get_cursor(0)[1] - 1,
        character = vim.api.nvim_win_get_cursor(0)[2],
      }

      local function find_path(items)
        for _, symbol in ipairs(items) do
          local range = symbol_range(symbol)
          if range and position_in_range(position, range) then
            local child_path = find_path(symbol_children(symbol))
            table.insert(child_path, 1, stl_escape(symbol.name))
            return child_path
          end
        end

        return {}
      end

      return find_path(symbols)
    end

    local function has_document_symbols(client)
      return client.supports_method and client:supports_method("textDocument/documentSymbol")
        or client.server_capabilities and client.server_capabilities.documentSymbolProvider
    end

    local function request_symbols(bufnr)
      if vim.bo[bufnr].buftype ~= "" then
        return
      end

      local clients = vim.lsp.get_clients({ bufnr = bufnr })
      if not vim.iter(clients):any(has_document_symbols) then
        symbol_cache[bufnr] = nil
        return
      end

      vim.lsp.buf_request_all(
        bufnr,
        "textDocument/documentSymbol",
        { textDocument = vim.lsp.util.make_text_document_params(bufnr) },
        function(results)
          if not vim.api.nvim_buf_is_valid(bufnr) then
            return
          end

          local symbols = {}
          for _, result in pairs(results) do
            if result.result then
              vim.list_extend(symbols, result.result)
            end
          end

          symbol_cache[bufnr] = symbols
          if bufnr == vim.api.nvim_get_current_buf() then
            vim.schedule(function()
              if vim.api.nvim_buf_is_valid(bufnr) and bufnr == vim.api.nvim_get_current_buf() then
                update_winbar()
              end
            end)
          end
        end
      )
    end

    update_winbar = function()
      if vim.bo.buftype ~= "" then
        vim.wo.winbar = ""
        return
      end

      local path = vim.fn.expand("%:~:.")
      if path == "" then
        vim.wo.winbar = "[No Name]"
        return
      end

      local parts = vim.split(path, "/", { plain = true })
      local filename = parts[#parts]
      local ext = vim.fn.expand("%:e")

      local icon_str = ""
      local ok, devicons = pcall(require, "nvim-web-devicons")
      if ok then
        local ic, color = devicons.get_icon_color(filename, ext, { default = true })
        if ic and color then
          vim.api.nvim_set_hl(0, "WinbarFileIcon", { fg = color })
          icon_str = "%#WinbarFileIcon#" .. ic .. "%* "
        end
      end

      local dirs = {}
      for i = 1, #parts - 1 do
        table.insert(dirs, parts[i])
      end

      local modified = vim.bo.modified and " ●" or ""
      local file_part = icon_str .. stl_escape(filename) .. modified
      local symbol_path = current_symbol_path(symbol_cache[vim.api.nvim_get_current_buf()])
      if #symbol_path > 0 then
        file_part = file_part .. " > " .. table.concat(symbol_path, " > ")
      end

      if #dirs > 0 then
        vim.wo.winbar = "%<" .. table.concat(vim.tbl_map(stl_escape, dirs), " > ") .. " > " .. file_part
      else
        vim.wo.winbar = "%<" .. file_part
      end
    end

    vim.api.nvim_create_autocmd({ "BufEnter", "BufModifiedSet", "CursorMoved", "CursorMovedI" }, {
      callback = function()
        update_winbar()
      end,
    })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave", "LspAttach" }, {
      callback = function(args)
        request_symbols(args.buf)
      end,
    })
  end,
}
