return {
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      -- list of servers for mason to install
      ensure_installed = {
        "ts_ls", -- TypeScript / JavaScript
        "gopls", -- Go
        -- dartls is provided by Dart/Flutter SDK, not Mason
      },
    },
    dependencies = {
      {
        "williamboman/mason.nvim",
        opts = {
          ui = {
            icons = {
              package_installed = "✓",
              package_pending = "➜",
              package_uninstalled = "✗",
            },
          },
        },
      },
      "neovim/nvim-lspconfig",
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "prettier",  -- TypeScript/JS formatter
        "stylua",    -- Lua formatter
        "eslint_d",  -- TypeScript/JS linter
        "goimports", -- Go formatter
      },
    },
    dependencies = {
      "williamboman/mason.nvim",
    },
  },
}
