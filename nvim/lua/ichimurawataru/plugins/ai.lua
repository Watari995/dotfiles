local state_file = vim.fn.stdpath("state") .. "/supermaven-enabled"

local function is_enabled()
  if vim.fn.filereadable(state_file) == 0 then
    return true
  end

  return vim.fn.readfile(state_file)[1] ~= "false"
end

local function save_enabled(enabled)
  vim.fn.mkdir(vim.fn.fnamemodify(state_file, ":h"), "p")
  vim.fn.writefile({ tostring(enabled) }, state_file)
end

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

    if not is_enabled() then
      require("supermaven-nvim.api").stop()
    end
  end,
  keys = {
    {
      "<leader>at",
      function()
        local api = require("supermaven-nvim.api")
        if api.is_running() then
          api.stop()
          save_enabled(false)
          vim.notify("Supermaven disabled")
        else
          api.start()
          save_enabled(true)
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
