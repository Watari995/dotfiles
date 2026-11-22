return {
  "saghen/blink.cmp",
  version = "1.*",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "folke/lazydev.nvim", opts = {} },
    {
      "L3MON4D3/LuaSnip",
      build = "make install_jsregexp && codesign --force --sign - --timestamp=none deps/luasnip-jsregexp.so",
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
    },
    "rafamadriz/friendly-snippets",
  },
  config = function(_, opts)
    require("blink.cmp").setup(opts)
    local capabilities = require("blink.cmp").get_lsp_capabilities()

    vim.lsp.config("*", {
      capabilities = capabilities,
    })

    -- dartls is provided by the Dart/Flutter SDK, so Mason does not enable it.
    vim.lsp.enable("dartls")
  end,
  opts = {
    keymap = {
      preset = "none",
      ["<C-k>"] = { "select_prev", "fallback" },
      ["<C-j>"] = { "select_next", "fallback" },
      ["<C-b>"] = {
        function(cmp)
          return cmp.scroll_documentation_up(4)
        end,
        "fallback",
      },
      ["<C-d>"] = {
        function(cmp)
          return cmp.scroll_documentation_down(4)
        end,
        "fallback",
      },
      ["<C-Space>"] = { "show", "show_documentation", "fallback" },
      ["<C-e>"] = { "cancel", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
    },
    snippets = { preset = "luasnip" },
    sources = {
      default = { "lazydev", "lsp", "snippets", "buffer", "path" },
      providers = {
        lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
      },
    },
    completion = {
      list = { selection = { preselect = false, auto_insert = false } },
      documentation = { auto_show = true },
    },
  },
}
