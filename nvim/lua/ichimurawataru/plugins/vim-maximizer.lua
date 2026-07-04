return {
  "szw/vim-maximizer",
  keys = {
    {
      "<leader>sm",
      function()
        local explorer = Snacks.picker.get({ source = "explorer" })[1]
        local explorer_win
        local explorer_width

        if explorer then
          explorer_win = explorer.layout and explorer.layout.root and explorer.layout.root.win
          local list_win = explorer.list and explorer.list.win and explorer.list.win.win
          if
            explorer_win
            and vim.api.nvim_win_is_valid(explorer_win)
            and list_win
            and vim.api.nvim_win_is_valid(list_win)
          then
            -- The visible list width can differ from Snacks' configured layout
            -- width after a manual resize. Persist the visible width first so a
            -- subsequent layout update does not snap back to the old value.
            explorer_width = vim.api.nvim_win_get_width(list_win)
            explorer.layout.opts.layout.width = explorer_width
          end
        end

        local was_maximized = vim.t.maximizer_sizes ~= nil
        vim.cmd("MaximizerToggle")

        if not was_maximized and explorer_width and vim.api.nvim_win_is_valid(explorer_win) then
          vim.api.nvim_win_set_width(explorer_win, explorer_width)
          explorer.layout:update()
          local sizes = vim.t.maximizer_sizes
          sizes.after = vim.fn.winrestcmd()
          vim.t.maximizer_sizes = sizes
        end
      end,
      desc = "Maximize/minimize a split while preserving explorer width",
    },
  },
}
