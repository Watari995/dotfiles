return {
  "nvim-treesitter/nvim-treesitter-context",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {
    mode = "cursor",
    max_lines = 3,
    trim_scope = "outer",
  },
  config = function(_, opts)
    require("treesitter-context").setup(opts)

    local function set_highlights()
      local bg = "#143652"
      local border = "#547998"
      vim.api.nvim_set_hl(0, "TreesitterContext", { bg = bg })
      vim.api.nvim_set_hl(0, "TreesitterContextLineNumber", { bg = bg, fg = "#B4D0E9" })
      vim.api.nvim_set_hl(0, "TreesitterContextBottom", { bg = bg, underline = true, sp = border })
      vim.api.nvim_set_hl(
        0,
        "TreesitterContextLineNumberBottom",
        { bg = bg, fg = "#B4D0E9", underline = true, sp = border }
      )
    end

    set_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = set_highlights,
    })
  end,
}
