return {
  "polarmutex/git-worktree.nvim",
  version = "^2",
  cmd = { "Worktree" },
  dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim" },
  config = function()
    -- Keep the current file when it does not exist in the destination worktree.
    vim.g.git_worktree = { update_on_change_command = "" }
    local hooks = require("git-worktree.hooks")
    hooks.register(hooks.type.SWITCH, function(path, previous)
      hooks.builtins.update_current_buffer_on_switch(path, previous)
      for _, picker in ipairs(Snacks.picker.get({ source = "explorer", tab = false })) do
        picker:set_cwd(path)
        picker:find()
      end
    end)

    vim.api.nvim_create_user_command("Worktree", function()
      local win, buf = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()
      if vim.bo[buf].buftype ~= "" or vim.api.nvim_win_get_config(win).relative ~= "" then
        vim.notify("Run :Worktree from a file window", vim.log.levels.WARN)
        return
      end

      local root = vim.fs.root(vim.fn.getcwd(), { ".git" })
      if not root then
        vim.notify("Current directory is not in a Git worktree", vim.log.levels.WARN)
        return
      end
      local result = vim.system({ "git", "-C", root, "worktree", "list", "--porcelain", "-z" }):wait(10000)
      if result.code ~= 0 then
        vim.notify(result.stderr or "Could not list worktrees", vim.log.levels.ERROR)
        return
      end
      local worktrees = {}
      for field in result.stdout:gmatch("([^%z]+)%z") do
        if field:sub(1, 9) == "worktree " then
          worktrees[#worktrees + 1] = field:sub(10)
        end
      end

      vim.ui.select(worktrees, { prompt = "Worktree" }, function(path)
        if not path or not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_buf(win) ~= buf then
          return
        end
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
          if vim.bo[b].modified then
            vim.notify("Save or discard unsaved changes before switching worktrees", vim.log.levels.WARN)
            return
          end
        end
        if vim.fn.isdirectory(path) ~= 1 then
          vim.notify("Worktree directory does not exist", vim.log.levels.WARN)
          return
        end
        vim.api.nvim_set_current_win(win)
        -- The plugin maps the file relative to the previous cwd, so start at its root.
        vim.cmd({ cmd = "cd", args = { root }, magic = { file = false } })
        require("git-worktree").switch_worktree(path)
      end)
    end, { desc = "Choose a worktree and switch the current file" })
  end,
}
