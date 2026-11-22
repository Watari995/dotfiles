return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    {
      "rcarriga/nvim-notify",
      opts = {
        stages = "static",
        timeout = 3000,
        render = "wrapped-compact",
        max_height = function()
          return math.floor(vim.o.lines * 0.75)
        end,
        max_width = function()
          return math.floor(vim.o.columns * 0.50)
        end,
      },
    },
  },
  opts = {
    lsp = {
      hover = { enabled = false },
      signature = { enabled = true },
    },
    presets = {
      bottom_search = false,
      command_palette = true,
      long_message_to_split = true,
    },
    routes = {
      -- Keep the existing suppression of noisy LSP file-watcher notifications.
      { filter = { event = "notify", find = "^watch%.watch:" }, opts = { skip = true } },
    },
  },
  config = function(_, opts)
    require("noice").setup(opts)
    vim.opt.cmdheight = 0
  end,
}
