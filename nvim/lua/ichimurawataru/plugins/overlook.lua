return {
  "WilliamHsieh/overlook.nvim",
  opts = {},
  keys = {
    {
      "<leader>pd",
      function()
        require("overlook.api").peek_definition()
      end,
      desc = "Peek definition",
    },
    {
      "<leader>pc",
      function()
        require("overlook.api").close_all()
      end,
      desc = "Close all definition previews",
    },
  },
}
