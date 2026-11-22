return {
  "folke/sidekick.nvim",
  version = "*",
  dependencies = { "folke/snacks.nvim" },
  opts = {
    nes = { enabled = false },
    cli = {
      mux = { enabled = false },
      tools = { claude = { cmd = { "claude", "--dangerously-skip-permissions" } } },
      win = {
        layout = "right",
        split = { width = 0.35 },
        keys = {
          buffers = false,
          files = false,
          prompt = false,
        },
      },
    },
  },
  keys = {
    {
      "<leader>ll",
      function()
        require("sidekick.cli").toggle({ name = "claude", focus = true })
      end,
      desc = "Toggle Claude Code",
    },
  },
}
