return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      javascript = { "eslint_d" },
      typescript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      typescriptreact = { "eslint_d" },
    }

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    local function file_in_cwd(file_name)
      return vim.fs.find(file_name, {
        upward = true,
        stop = vim.loop.cwd():match("(.+)/"),
        path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
        type = "file",
      })[1]
    end

    local eslint_config_names = {
      "eslint.config.js",
      "eslint.config.mjs",
      "eslint.config.cjs",
      ".eslintrc.cjs",
      ".eslintrc.js",
      ".eslintrc.json",
    }

    local function try_linting()
      local linters = lint.linters_by_ft[vim.bo.filetype]
      if linters and vim.api.nvim_buf_get_name(0) ~= "" then
        for _, name in ipairs(eslint_config_names) do
          if file_in_cwd(name) then
            lint.try_lint(linters)
            break
          end
        end
      end
    end

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = try_linting,
    })

    vim.keymap.set("n", "<leader>l", try_linting, { desc = "Trigger linting for current file" })
  end,
}
