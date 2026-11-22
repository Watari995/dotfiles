local required_parsers = { "go", "gotmpl", "html", "sql" }

vim.filetype.add({
  pattern = {
    [".*/src/templates/.*%.html"] = "gotmpl",
  },
})

return {
  "nvim-treesitter/nvim-treesitter",
  build = function()
    require("nvim-treesitter").install(required_parsers):wait(300000)
    require("nvim-treesitter").update():wait(300000)
  end,
  config = function()
    -- nvim-treesitter v1 stores queries in runtime/ which lazy.nvim doesn't add to rtp.
    -- Appended so Neovim's own queries take priority for bundled languages (lua, etc.).
    -- After running :TSInstall, site/queries/ takes priority over this anyway.
    local ts_dir = require("lazy.core.config").plugins["nvim-treesitter"].dir
    vim.opt.runtimepath:append(ts_dir .. "/runtime")

    -- Use Neovim's built-in YAML indentation for predictable list continuation.
    local skip_ts_indent = { go = true, c = true, yaml = true }
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
        if not skip_ts_indent[vim.bo[args.buf].filetype] then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })

    vim.treesitter.language.register("bash", "zsh")
  end,
}
