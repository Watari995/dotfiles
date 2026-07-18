local sticky_ns = vim.api.nvim_create_namespace("snacks_explorer_sticky_scroll")
local explorer_hidden_state_file = vim.fn.stdpath("state") .. "/snacks-explorer-hidden"
local explorer_width_state_file = vim.fn.stdpath("state") .. "/snacks-explorer-width"
local explorer_breadcrumb_group = vim.api.nvim_create_augroup("SnacksExplorerBreadcrumb", { clear = true })
local closing_sticky_scroll = false

local function read_explorer_hidden()
  local ok, lines = pcall(vim.fn.readfile, explorer_hidden_state_file)
  if not ok or #lines == 0 then
    return true
  end
  return lines[1] == "true"
end

local function write_explorer_hidden(hidden)
  vim.fn.mkdir(vim.fn.stdpath("state"), "p")
  pcall(vim.fn.writefile, { hidden and "true" or "false" }, explorer_hidden_state_file)
end

local function read_explorer_width()
  local ok, lines = pcall(vim.fn.readfile, explorer_width_state_file)
  if not ok or #lines == 0 then
    return nil
  end

  local width = tonumber(lines[1])
  if not width or width < 1 then
    return nil
  end
  return width
end

local function write_explorer_width(width)
  if not width or width < 1 then
    return
  end
  vim.fn.mkdir(vim.fn.stdpath("state"), "p")
  pcall(vim.fn.writefile, { tostring(width) }, explorer_width_state_file)
end

local function visible_explorer_width(picker)
  local list_win = picker and picker.list and picker.list.win and picker.list.win.win
  if list_win and vim.api.nvim_win_is_valid(list_win) then
    return vim.api.nvim_win_get_width(list_win)
  end

  local root_win = picker and picker.layout and picker.layout.root and picker.layout.root.win
  if root_win and vim.api.nvim_win_is_valid(root_win) then
    return vim.api.nvim_win_get_width(root_win)
  end
end

local function save_explorer_width(picker)
  write_explorer_width(visible_explorer_width(picker))
end

local function save_open_explorer_widths()
  local ok, snacks = pcall(require, "snacks")
  if not ok or not snacks.picker then
    return
  end

  for _, picker in ipairs(snacks.picker.get({ source = "explorer", tab = false })) do
    save_explorer_width(picker)
  end
end

local function toggle_explorer_hidden(picker)
  picker.opts.hidden = not picker.opts.hidden
  write_explorer_hidden(picker.opts.hidden)
  picker.list:set_target()
  picker:find()
end

local function explorer_opts()
  local opts = { hidden = read_explorer_hidden() }
  local width = read_explorer_width()
  if width then
    opts.layout = {
      layout = {
        width = width,
        min_width = math.min(width, 40),
      },
    }
  end
  return opts
end

local function open_explorer()
  save_open_explorer_widths()
  Snacks.explorer(explorer_opts())
end

local function reveal_explorer()
  save_open_explorer_widths()

  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    return open_explorer()
  end

  local explorer = Snacks.picker.get({ source = "explorer" })[1]
  local function reveal()
    Snacks.explorer.reveal({ file = file })
  end

  if explorer then
    reveal()
  else
    local opts = explorer_opts()
    opts.on_show = reveal
    explorer = Snacks.explorer(opts)
  end
  return explorer
end

local function close_sticky_scroll(picker)
  local sticky = picker._explorer_sticky_scroll
  if not sticky then
    return
  end
  if sticky.win and vim.api.nvim_win_is_valid(sticky.win) then
    closing_sticky_scroll = true
    pcall(vim.api.nvim_win_close, sticky.win, true)
    closing_sticky_scroll = false
  end
  if sticky.buf and vim.api.nvim_buf_is_valid(sticky.buf) then
    vim.api.nvim_buf_delete(sticky.buf, { force = true })
  end
  picker._explorer_sticky_scroll = nil
end

local function parent_name(item)
  if item.text and item.text ~= "" then
    return vim.fn.fnamemodify(item.text, ":t")
  end
  if item.file and item.file ~= "" then
    return vim.fn.fnamemodify(item.file, ":t")
  end
end

local function breadcrumb_width(segments, omitted)
  local text = "▸ "
  if omitted then
    text = text .. "…"
    if #segments > 0 then
      text = text .. " > "
    end
  end
  text = text .. table.concat(segments, " > ")
  return vim.fn.strdisplaywidth(text)
end

local function fit_breadcrumb_segments(segments, width)
  local shown = {}
  for i = #segments, 1, -1 do
    table.insert(shown, 1, segments[i])
    if breadcrumb_width(shown, i > 1) > width then
      table.remove(shown, 1)
      break
    end
  end

  while #shown > 1 and breadcrumb_width(shown, #shown < #segments) > width do
    table.remove(shown, 1)
  end

  return shown, #shown < #segments
end

local function build_breadcrumb_line(segments, width)
  local shown, omitted = fit_breadcrumb_segments(segments, width)
  local text, marks = "", {}

  local function append(chunk, hl)
    local col = #text
    text = text .. chunk
    if hl then
      marks[#marks + 1] = {
        col = col,
        end_col = #text,
        hl_group = hl,
      }
    end
  end

  append("▸ ", "SnacksExplorerBreadcrumbPrefix")
  if omitted then
    append("…", "SnacksExplorerBreadcrumbSep")
    if #shown > 0 then
      append(" > ", "SnacksExplorerBreadcrumbSep")
    end
  end
  for i, segment in ipairs(shown) do
    if i > 1 then
      append(" > ", "SnacksExplorerBreadcrumbSep")
    end
    append(segment, "SnacksExplorerBreadcrumbDir")
  end

  return text, marks
end

local function update_sticky_scroll(picker)
  local list = picker.list
  local list_win = list and list.win and list.win.win
  local root_win = picker.layout and picker.layout.root and picker.layout.root.win
  if
    picker.closed
    or not root_win
    or not vim.api.nvim_win_is_valid(root_win)
    or not list_win
    or not vim.api.nvim_win_is_valid(list_win)
  then
    return close_sticky_scroll(picker)
  end

  local item = list:current()
  local segments = {}
  item = item and item.parent
  while item do
    if not item.internal then
      local name = parent_name(item)
      if name and name ~= "" then
        table.insert(segments, 1, name)
      end
    end
    item = item.parent
  end

  if #segments == 0 then
    return close_sticky_scroll(picker)
  end

  local sticky = picker._explorer_sticky_scroll
  local width = vim.api.nvim_win_get_width(list_win)
  if
    sticky
    and (
      sticky.list_win ~= list_win
      or sticky.width ~= width
      or not sticky.win
      or not vim.api.nvim_win_is_valid(sticky.win)
      or not sticky.buf
      or not vim.api.nvim_buf_is_valid(sticky.buf)
    )
  then
    close_sticky_scroll(picker)
    sticky = nil
  end
  if not sticky then
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].filetype = "snacks_picker_list"
    local win = vim.api.nvim_open_win(buf, false, {
      relative = "win",
      win = list_win,
      row = 0,
      col = 0,
      width = width,
      height = 1,
      style = "minimal",
      focusable = false,
      mouse = false,
      -- Keep this above the explorer and below LazyGit (zindex 52).
      zindex = 51,
    })
    vim.wo[win].winhighlight = vim.wo[list_win].winhighlight
    sticky = { buf = buf, win = win, list_win = list_win, width = width }
    picker._explorer_sticky_scroll = sticky
  end

  local cursor_row = vim.api.nvim_win_call(list_win, function()
    return vim.fn.winline()
  end)
  local row = cursor_row == 1 and 1 or 0
  vim.api.nvim_win_set_config(sticky.win, {
    relative = "win",
    win = list_win,
    row = row,
    col = 0,
    width = width,
    height = 1,
  })
  sticky.width = width

  local line, marks = build_breadcrumb_line(segments, width)

  vim.bo[sticky.buf].modifiable = true
  vim.api.nvim_buf_set_lines(sticky.buf, 0, -1, false, { line })
  vim.api.nvim_buf_clear_namespace(sticky.buf, sticky_ns, 0, -1)
  for _, extmark in ipairs(marks) do
    local col = extmark.col or 0
    extmark = vim.deepcopy(extmark)
    extmark.col = nil
    pcall(vim.api.nvim_buf_set_extmark, sticky.buf, sticky_ns, 0, col, extmark)
  end
  vim.bo[sticky.buf].modifiable = false
end

local function schedule_sticky_scroll(picker)
  if picker._explorer_sticky_pending then
    return
  end
  picker._explorer_sticky_pending = true
  vim.schedule(function()
    picker._explorer_sticky_pending = nil
    if not picker.closed then
      update_sticky_scroll(picker)
    end
  end)
end

_G.close_snacks_explorer_sticky_scroll = function()
  local ok, snacks = pcall(require, "snacks")
  if not ok or not snacks.picker then
    return
  end
  for _, picker in ipairs(snacks.picker.get({ source = "explorer", tab = false })) do
    close_sticky_scroll(picker)
  end
end

local function refresh_explorer_sticky_scroll()
  local ok, snacks = pcall(require, "snacks")
  if not ok or not snacks.picker then
    return
  end
  for _, picker in ipairs(snacks.picker.get({ source = "explorer", tab = false })) do
    close_sticky_scroll(picker)
    schedule_sticky_scroll(picker)
  end
end

_G.refresh_snacks_explorer_sticky_scroll = refresh_explorer_sticky_scroll
_G.save_snacks_explorer_widths = save_open_explorer_widths
_G.reveal_snacks_explorer = reveal_explorer

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    explorer = {
      enabled = true,
      replace_netrw = true,
    },
    picker = {
      enabled = true,
      actions = {
        trouble_open = function(picker)
          require("trouble.sources.snacks").open(picker)
        end,
      },
      win = {
        input = {
          keys = {
            ["<C-t>"] = { "trouble_open", mode = { "n", "i" } },
            ["<C-x>"] = { "edit_split", mode = { "n", "i" } },
          },
        },
      },
      sources = {
        explorer = {
          hidden = read_explorer_hidden(),
          ignored = true,
          actions = {
            toggle_explorer_hidden = toggle_explorer_hidden,
          },
          main = { file = false },
          layout = {
            hidden = { "input" },
            auto_hide = { "input" },
          },
          win = {
            list = {
              keys = {
                ["<CR>"] = "confirm",
                ["H"] = "toggle_explorer_hidden",
                ["l"] = "confirm",
              },
            },
          },
          on_change = function(picker)
            -- on_change does not fire when the list scrolls without moving the
            -- cursor, so also update after every list render.
            if not picker._explorer_sticky_render then
              local render = picker.list.render
              picker.list.render = function(list, ...)
                local ret = render(list, ...)
                schedule_sticky_scroll(picker)
                return ret
              end
              picker._explorer_sticky_render = true
            end
            schedule_sticky_scroll(picker)
          end,
          on_close = function(picker)
            save_explorer_width(picker)
            close_sticky_scroll(picker)
          end,
        },
        files = {
          hidden = true,
          ignored = false,
          exclude = {
            ".git",
            "public/assets",
            "node_modules",
            "dist",
            "build",
          },
        },
        lsp_references = {
          format = function(item, picker)
            return Snacks.picker.format.filename(item, picker)
          end,
        },
        lsp_implementations = {
          format = function(item, picker)
            return Snacks.picker.format.filename(item, picker)
          end,
        },
      },
    },
  },
  config = function(_, opts)
    require("snacks").setup(opts)

    local picker_format = require("snacks.picker.format")
    local filename_format = picker_format.filename
    picker_format.filename = function(item, picker)
      if not item.pos or item.pos[2] <= 0 then
        return filename_format(item, picker)
      end

      local formatted_item = vim.tbl_extend("force", item, {
        pos = { item.pos[1], 0 },
      })
      return filename_format(formatted_item, picker)
    end

    vim.ui.select = Snacks.picker.select

    local function set_picker_highlights()
      vim.api.nvim_set_hl(0, "SnacksPickerDir", { link = "Comment" })
      vim.api.nvim_set_hl(0, "SnacksExplorerBreadcrumbPrefix", { link = "DiagnosticInfo" })
      vim.api.nvim_set_hl(0, "SnacksExplorerBreadcrumbDir", { link = "Directory" })
      vim.api.nvim_set_hl(0, "SnacksExplorerBreadcrumbSep", { link = "Comment" })
    end
    set_picker_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = set_picker_highlights,
    })
    vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
      group = explorer_breadcrumb_group,
      callback = function()
        vim.schedule(function()
          save_open_explorer_widths()
          refresh_explorer_sticky_scroll()
        end)
      end,
    })
    vim.api.nvim_create_autocmd("WinClosed", {
      group = explorer_breadcrumb_group,
      callback = function()
        if closing_sticky_scroll then
          return
        end
        vim.schedule(refresh_explorer_sticky_scroll)
      end,
    })
  end,
  keys = {
    {
      "<leader>ee",
      function()
        open_explorer()
      end,
      desc = "Toggle file explorer",
    },
    {
      "<leader>ef",
      function()
        local explorer = Snacks.picker.get({ source = "explorer" })[1]
        if explorer then
          explorer:close()
        else
          reveal_explorer()
        end
      end,
      desc = "Toggle file explorer on current file",
    },
    {
      "<leader>ec",
      function()
        local explorer = Snacks.picker.get({ source = "explorer" })[1]
        if explorer then
          explorer:action("explorer_close_all")
        end
      end,
      desc = "Collapse file explorer",
    },
    {
      "<leader>er",
      function()
        local explorer = Snacks.picker.get({ source = "explorer" })[1]
        if explorer then
          explorer:action("explorer_update")
        end
      end,
      desc = "Refresh file explorer",
    },
    {
      "<leader>ff",
      function()
        Snacks.picker.files()
      end,
      desc = "Find files",
    },
    {
      "<leader>fr",
      function()
        Snacks.picker.recent()
      end,
      desc = "Find recent files",
    },
    {
      "<leader>fs",
      function()
        Snacks.picker.grep()
      end,
      desc = "Find string in cwd",
    },
    {
      "<leader>fc",
      function()
        Snacks.picker.grep_word()
      end,
      mode = { "n", "x" },
      desc = "Find string under cursor or selection",
    },
    {
      "<leader>ft",
      function()
        Snacks.picker.sources.todo_comments = require("todo-comments.snacks").source
        Snacks.picker.pick("todo_comments")
      end,
      desc = "Find todos",
    },
    {
      "<leader>fk",
      function()
        Snacks.picker.keymaps()
      end,
      desc = "Find keymaps",
    },
  },
}
