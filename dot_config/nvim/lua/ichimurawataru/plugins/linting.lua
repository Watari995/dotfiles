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

    local function remove_linter(linters, linter_name)
      for k, v in pairs(linters) do
        if v == linter_name then
          linters[k] = nil
          break
        end
      end
    end

    local function linter_in_linters(linters, linter_name)
      for k, v in pairs(linters) do
        if v == linter_name then
          return true
        end
      end
      return false
    end

    local function remove_linter_if_missing_config_file(linters, linter_name, config_file_name)
      if linter_in_linters(linters, linter_name) and not file_in_cwd(config_file_name) then
        remove_linter(linters, linter_name)
      end
    end

    local function try_linting()
      local linters = lint.linters_by_ft[vim.bo.filetype]

      if linters then
        remove_linter_if_missing_config_file(linters, "eslint_d", "eslint.config.js")
      end

      lint.try_lint(linters)
      lint.try_lint({ "cspell" })
    end

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        try_linting()
      end,
    })

    local function add_word_to_cspell()
      local word = vim.fn.expand("<cword>")
      if word == "" then return end

      -- プロジェクトの cspell.json を優先、なければ ~/.cspell.json
      local project_config = vim.fn.findfile("cspell.json", vim.fn.getcwd() .. ";")
      local config_path = project_config ~= "" and vim.fn.fnamemodify(project_config, ":p")
        or vim.env.HOME .. "/.cspell.json"

      -- 既存の設定を読み込む
      local config = {}
      local file = io.open(config_path, "r")
      if file then
        local ok, decoded = pcall(vim.fn.json_decode, file:read("*a"))
        file:close()
        if ok then config = decoded end
      end

      -- 重複チェック
      config.words = config.words or {}
      for _, w in ipairs(config.words) do
        if w == word then
          vim.notify("cspell: '" .. word .. "' は登録済みです", vim.log.levels.INFO)
          return
        end
      end

      -- 追加してソート
      table.insert(config.words, word)
      table.sort(config.words)

      -- 整形して書き戻す
      local json_str = vim.fn.json_encode(config)
      local pretty = vim.fn.system("echo " .. vim.fn.shellescape(json_str) .. " | python3 -m json.tool")
      local out = io.open(config_path, "w")
      if out then
        out:write(pretty)
        out:close()
        vim.notify("cspell: '" .. word .. "' を追加 → " .. config_path, vim.log.levels.INFO)
        lint.try_lint({ "cspell" })
      end
    end

    vim.keymap.set("n", "<leader>l", function()
      try_linting()
    end, { desc = "Trigger linting for current file" })

    vim.keymap.set("n", "<leader>wa", add_word_to_cspell, { desc = "cspell: add word under cursor" })
  end,
}
