return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local startify = require("alpha.themes.startify")
    local header_width = 52
    startify.config.opts.margin = math.max(0, math.floor((vim.o.columns - header_width) / 2))
    startify.config.opts.redraw_on_resize = true
    require("alpha").setup(startify.config)
    vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
  end,
}
