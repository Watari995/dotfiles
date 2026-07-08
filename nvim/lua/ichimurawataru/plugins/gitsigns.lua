local function system(cmd, opts, on_exit)
  opts = opts or {}
  opts.text = true
  vim.system(cmd, opts, function(result)
    vim.schedule(function()
      on_exit(result.code, result.stdout or "", result.stderr or "")
    end)
  end)
end

local function systemlist(cmd, cwd)
  local result = vim.system(cmd, { cwd = cwd, text = true }):wait()
  if result.code ~= 0 then
    return nil
  end
  return vim.split(vim.trim(result.stdout or ""), "\n", { plain = true, trimempty = true })
end

local function parse_github_remote(remote)
  if not remote then
    return nil
  end

  local owner, repo = remote:match("^git@github%.com:([^/]+)/(.+)$")
  if not owner then
    owner, repo = remote:match("^https://github%.com/([^/]+)/(.+)$")
  end
  if not owner then
    owner, repo = remote:match("^ssh://git@github%.com/([^/]+)/(.+)$")
  end
  if not owner or not repo then
    return nil
  end

  repo = repo:gsub("%.git$", "")
  return owner, repo
end

local function parse_blame(stdout)
  local info = {}
  for line in stdout:gmatch("[^\n]+") do
    if not info.sha then
      info.sha = line:match("^([0-9a-f]+) %d+ %d+ %d+$")
    end
    local key, value = line:match("^([%w-]+) (.*)$")
    if key == "author" then
      info.author = value
    elseif key == "author-mail" then
      info.author_mail = value:gsub("^<", ""):gsub(">$", "")
    elseif key == "author-time" then
      info.author_time = tonumber(value)
    elseif key == "summary" then
      info.summary = value
    elseif key == "filename" then
      info.filename = value
    end
  end
  return info
end

local function open_blame_float(initial_lines)
  local source_win = vim.api.nvim_get_current_win()
  local source_cursor = vim.api.nvim_win_get_cursor(source_win)
  local screenpos = vim.fn.screenpos(source_win, source_cursor[1], source_cursor[2] + 1)
  local anchor = {
    row = screenpos.row > 0 and screenpos.row or math.floor(vim.o.lines * 0.4),
    col = screenpos.col > 0 and screenpos.col + 1 or math.floor(vim.o.columns * 0.25),
  }
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "markdown"

  local function float_config(lines)
    local width = 50
    for _, line in ipairs(lines) do
      width = math.max(width, vim.fn.strdisplaywidth(line))
    end
    width = math.min(width, math.floor(vim.o.columns * 0.8))
    local height = math.min(#lines, math.floor(vim.o.lines * 0.6))
    local row = math.min(anchor.row, math.max(0, vim.o.lines - height - 2))
    local col = math.min(anchor.col, math.max(0, vim.o.columns - width - 2))

    return {
      relative = "editor",
      row = row,
      col = col,
      width = width,
      height = height,
    }
  end

  local function set_lines(lines)
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false

    local win = vim.fn.bufwinid(buf)
    if win ~= -1 then
      vim.api.nvim_win_set_config(win, float_config(lines))
    end
  end

  set_lines(initial_lines)
  local config = vim.tbl_extend("force", float_config(initial_lines), {
    style = "minimal",
    border = "rounded",
    title = " Git Blame ",
    title_pos = "center",
  })
  local win = vim.api.nvim_open_win(buf, true, config)
  vim.wo[win].wrap = false
  vim.wo[win].cursorline = true

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  local function current_url()
    local line = vim.api.nvim_get_current_line()
    return line:match("https://%S+")
  end

  vim.keymap.set("n", "q", close, { buffer = buf, nowait = true, desc = "Close" })
  vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true, desc = "Close" })
  vim.keymap.set("n", "o", function()
    local url = current_url()
    if url then
      vim.ui.open(url)
    end
  end, { buffer = buf, desc = "Open URL" })
  vim.keymap.set("n", "y", function()
    local url = current_url()
    if url then
      vim.fn.setreg("+", url)
      vim.notify("Copied: " .. url, vim.log.levels.INFO)
    end
  end, { buffer = buf, desc = "Copy URL" })

  return set_lines
end

local function show_blame_with_pr()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("No file for blame", vim.log.levels.WARN)
    return
  end

  local file_dir = vim.fn.fnamemodify(file, ":p:h")
  local root = systemlist({ "git", "rev-parse", "--show-toplevel" }, file_dir)
  root = root and root[1]
  if not root then
    vim.notify("Not inside a git repository", vim.log.levels.WARN)
    return
  end

  local relative = vim.fn.fnamemodify(file, ":p"):sub(#root + 2)
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local update = open_blame_float({ "Loading blame..." })

  system(
    { "git", "blame", "--line-porcelain", "-L", line .. "," .. line, "--", relative },
    { cwd = root },
    function(code, stdout, stderr)
      if code ~= 0 then
        update({
          "Git blame failed",
          "",
          vim.trim(stderr),
        })
        return
      end

      local blame = parse_blame(stdout)
      if not blame.sha or blame.sha:match("^0+$") then
        update({ "Not committed yet", "", relative .. ":" .. line })
        return
      end

      local remotes = systemlist({ "git", "config", "--get", "remote.origin.url" }, root)
      local owner, repo = parse_github_remote(remotes and remotes[1])
      local date = blame.author_time and os.date("%Y-%m-%d %H:%M:%S", blame.author_time) or "unknown date"
      local short_sha = blame.sha:sub(1, 12)
      local lines = {
        blame.summary or "(no summary)",
        "",
        "Commit: " .. short_sha,
        "Author: " .. (blame.author or "unknown"),
        "Date:   " .. date,
        "File:   " .. (blame.filename or relative) .. ":" .. line,
      }

      if not owner then
        vim.list_extend(lines, {
          "",
          "PR:     remote.origin.url is not github.com",
        })
        update(lines)
        return
      end

      local commit_url = "https://github.com/" .. owner .. "/" .. repo .. "/commit/" .. blame.sha
      vim.list_extend(lines, {
        "",
        "Commit URL:",
        commit_url,
        "",
        "PR:",
        "Loading...",
      })
      update(lines)

      if vim.fn.executable("gh") ~= 1 then
        lines[#lines] = "gh command is not installed"
        update(lines)
        return
      end

      system({
        "gh",
        "api",
        "repos/" .. owner .. "/" .. repo .. "/commits/" .. blame.sha .. "/pulls",
        "-H",
        "Accept: application/vnd.github+json",
      }, { cwd = root }, function(gh_code, gh_stdout, gh_stderr)
        if gh_code ~= 0 then
          lines[#lines] = vim.trim(gh_stderr)
          update(lines)
          return
        end

        local ok, pulls = pcall(vim.json.decode, gh_stdout)
        if not ok or vim.tbl_isempty(pulls) then
          lines[#lines] = "No associated PR found"
          update(lines)
          return
        end

        lines[#lines] = "#" .. pulls[1].number .. " " .. pulls[1].title
        table.insert(lines, pulls[1].html_url)
        update(lines)
      end)
    end
  )
end

return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    current_line_blame_opts = {
      delay = 100,
    },
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end

      -- Navigation
      map("n", "]h", gs.next_hunk, "Next Hunk")
      map("n", "[h", gs.prev_hunk, "Prev Hunk")

      -- Actions
      map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
      map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
      map("v", "<leader>hs", function()
        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Stage hunk")
      map("v", "<leader>hr", function()
        gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Reset hunk")

      map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
      map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")

      map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")

      map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")

      map("n", "<leader>hb", show_blame_with_pr, "Blame line with PR")
      map("n", "<leader>hB", gs.toggle_current_line_blame, "Toggle line blame")

      map("n", "<leader>hd", gs.diffthis, "Diff this")
      map("n", "<leader>hD", function()
        gs.diffthis("~")
      end, "Diff this ~")

      -- Text object
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Gitsigns select hunk")
    end,
  },
}
