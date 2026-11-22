return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        vue = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        lua = { "stylua" },
        dart = { "dart_format" },
      },
      format_on_save = function(bufnr)
        if vim.bo[bufnr].filetype == "go" then
          return
        end
        return { lsp_format = "fallback", timeout_ms = 3000 }
      end,
    })

    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("GoFormatOnSave", { clear = true }),
      callback = function(args)
        if vim.bo[args.buf].filetype == "go" then
          require("ichimurawataru.go_format").format(args.buf)
        end
      end,
    })

    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
      if vim.bo.filetype == "go" then
        require("ichimurawataru.go_format").format()
        return
      end
      conform.format({
        lsp_format = "fallback",
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = "Format file or range (in visual mode)" })
  end,
}
