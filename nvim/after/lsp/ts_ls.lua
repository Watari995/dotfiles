local vue_language_server_path = vim.fn.stdpath("data")
  .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"

return {
  filetypes = { "javascript", "typescript", "vue" },
  root_dir = function(bufnr, on_dir)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local root = vim.fs.root(bufname, { "tsconfig.json", "jsconfig.json", "package.json", ".git" })

    if root then
      on_dir(root)
    end
  end,
  init_options = {
    plugins = {
      {
        name = "@vue/typescript-plugin",
        location = vue_language_server_path,
        languages = { "vue" },
      },
    },
  },
}
