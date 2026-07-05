return {
  "kdheepak/lazygit.nvim",
  cmd = {
    "LazyGit",
    "LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
    "LazyGitFilterCurrentFile",
  },
  -- optional for floating window border decoration
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  init = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "lazygit",
      callback = function(args)
        local win = vim.fn.bufwinid(args.buf)
        if win ~= -1 then
          -- Keep LazyGit above the Snacks explorer sticky scroll (zindex 51).
          vim.api.nvim_win_set_config(win, { zindex = 52 })
        end
      end,
    })
  end,
  -- setting the keybinding for LazyGit with 'keys' is recommended in
  -- order to load the plugin when the command is run for the first time
  keys = {
    { "<leader>lg", "<cmd>LazyGit<cr>", desc = "Open lazy git" },
  },
}
