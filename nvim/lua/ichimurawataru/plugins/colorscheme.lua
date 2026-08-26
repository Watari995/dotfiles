return {
  {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("onedark").setup({
        style = "dark",
      })
      vim.cmd.colorscheme("onedark")
      vim.api.nvim_set_hl(0, "YankHighlight", { link = "Visual" })
      vim.api.nvim_set_hl(0, "Search", { link = "Visual" })
      vim.api.nvim_set_hl(0, "IncSearch", { link = "Visual" })
      vim.api.nvim_set_hl(0, "CurSearch", { link = "Visual" })
    end,
  },
}
