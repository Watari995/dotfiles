return {
  "supermaven-inc/supermaven-nvim",
  event = "InsertEnter",
  config = function()
    require("supermaven-nvim").setup({
      keymaps = {
        accept_suggestion = "<Tab>",
        clear_suggestion = "<C-]>",
        accept_word = "<C-f>",
      },
      ignore_filetypes = {},
      color = {
        suggestion_color = "#ffffff",
        cterm = 244,
      },
      disable_inline_completion = false,
      disable_keymaps = false,
    })
  end,
  keys = {
    {
      "<leader>at",
      function()
        local api = require("supermaven-nvim.api")
        if api.is_running() then
          api.stop()
          vim.notify("Supermaven disabled")
        else
          api.start()
          vim.notify("Supermaven enabled")
        end
      end,
      desc = "Toggle Supermaven",
    },
    {
      "<leader>as",
      function()
        local api = require("supermaven-nvim.api")
        local status = api.is_running() and "enabled" or "disabled"
        vim.notify("Supermaven: " .. status)
      end,
      desc = "Show Supermaven status",
    },
  },
}
