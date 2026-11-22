return {
  "folke/persistence.nvim",
  version = "*",
  event = "BufReadPre",
  opts = { branch = false },
  config = function(_, opts)
    local persistence = require("persistence")
    persistence.setup(opts)

    -- Keep the previous exclusions for both automatic and manual saves.
    local save = persistence.save
    persistence.save = function()
      local cwd = vim.fn.getcwd():gsub("/+$", "")
      for _, dir in ipairs({ "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" }) do
        if cwd == vim.fn.expand(dir):gsub("/+$", "") then
          return
        end
      end
      save()
    end
  end,
  keys = {
    {
      "<leader>wr",
      function()
        require("persistence").load()
      end,
      desc = "Restore session for cwd",
    },
    {
      "<leader>ws",
      function()
        require("persistence").save()
      end,
      desc = "Save session for cwd",
    },
  },
}
