return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status") -- to configure lazy pending updates count

    -- configure lualine with modified theme
    lualine.setup({
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

    local function update_winbar()
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
      local file_part = icon_str .. filename .. modified

      if #dirs > 0 then
        vim.wo.winbar = table.concat(dirs, " > ") .. " > " .. file_part
      else
        vim.wo.winbar = file_part
      end
    end

    vim.api.nvim_create_autocmd({ "BufEnter", "BufModifiedSet" }, {
      callback = update_winbar,
    })
  end,
}
