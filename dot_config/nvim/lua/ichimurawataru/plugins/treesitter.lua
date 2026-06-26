return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    -- nvim-treesitter v1 stores queries in runtime/ which lazy.nvim doesn't add to rtp.
    -- Appended so Neovim's own queries take priority for bundled languages (lua, etc.).
    -- After running :TSInstall, site/queries/ takes priority over this anyway.
    local ts_dir = require("lazy.core.config").plugins["nvim-treesitter"].dir
    vim.opt.runtimepath:append(ts_dir .. "/runtime")

    local skip_ts_indent = { go = true, c = true }
    -- sql: pre-built sql.so is incompatible with bundled queries (keyword_object_id).
    -- Skip treesitter so Vim's built-in SQL syntax applies instead.
    -- Remove sql from this list after running :TSInstall sql (requires tree-sitter-cli).
    local skip_ts = { sql = true }

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        if not skip_ts[vim.bo[args.buf].filetype] then
          pcall(vim.treesitter.start, args.buf)
        end
        if not skip_ts_indent[vim.bo[args.buf].filetype] then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })

    vim.treesitter.language.register("bash", "zsh")
  end,
}
