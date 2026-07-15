local sticky_ns = vim.api.nvim_create_namespace("snacks_explorer_sticky_scroll")
local explorer_hidden_state_file = vim.fn.stdpath("state") .. "/snacks-explorer-hidden"

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

local function toggle_explorer_hidden(picker)
  picker.opts.hidden = not picker.opts.hidden
  write_explorer_hidden(picker.opts.hidden)
  picker.list:set_target()
  picker:find()
end

local function close_sticky_scroll(picker)
  local sticky = picker._explorer_sticky_scroll
  if not sticky then
    return
  end
  if sticky.win and vim.api.nvim_win_is_valid(sticky.win) then
    vim.api.nvim_win_close(sticky.win, true)
  end
  if sticky.buf and vim.api.nvim_buf_is_valid(sticky.buf) then
    vim.api.nvim_buf_delete(sticky.buf, { force = true })
  end
  picker._explorer_sticky_scroll = nil
end

local function update_sticky_scroll(picker)
  local list = picker.list
  local list_win = list and list.win and list.win.win
  if not list_win or not vim.api.nvim_win_is_valid(list_win) then
    return close_sticky_scroll(picker)
  end

  local item = list:get(list.top)
  local parents = {}
  item = item and item.parent
  while item do
    table.insert(parents, 1, item)
    item = item.parent
  end

  -- Do not let a very deep tree cover the whole explorer.
  local max_height = math.max(1, math.floor(vim.api.nvim_win_get_height(list_win) / 2))
  if #parents > max_height then
    parents = vim.list_slice(parents, #parents - max_height + 1)
  end
  if #parents == 0 then
    return close_sticky_scroll(picker)
  end

  local sticky = picker._explorer_sticky_scroll
  if sticky and sticky.list_win ~= list_win then
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
      width = vim.api.nvim_win_get_width(list_win),
      height = #parents,
      style = "minimal",
      focusable = false,
      mouse = false,
      -- Keep this above the explorer and below LazyGit (zindex 52).
      zindex = 51,
    })
    vim.wo[win].winhighlight = vim.wo[list_win].winhighlight
    sticky = { buf = buf, win = win, list_win = list_win }
    picker._explorer_sticky_scroll = sticky
  end

  vim.api.nvim_win_set_config(sticky.win, {
    relative = "win",
    win = list_win,
    row = 0,
    col = 0,
    width = vim.api.nvim_win_get_width(list_win),
    height = #parents,
  })

  local lines, marks = {}, {}
  for row, parent in ipairs(parents) do
    local text, extmarks = list:format(parent)
    lines[row] = text:gsub("\n", " ")
    marks[row] = extmarks
  end

  vim.bo[sticky.buf].modifiable = true
  vim.api.nvim_buf_set_lines(sticky.buf, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(sticky.buf, sticky_ns, 0, -1)
  for row, extmarks in ipairs(marks) do
    for _, extmark in ipairs(extmarks) do
      extmark = vim.deepcopy(extmark)
      local col = extmark.col or 0
      extmark.col = nil
      extmark.row = nil
      extmark.field = nil
      pcall(vim.api.nvim_buf_set_extmark, sticky.buf, sticky_ns, row - 1, col, extmark)
    end
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
    vim.ui.select = Snacks.picker.select

    local function set_picker_highlights()
      vim.api.nvim_set_hl(0, "SnacksPickerDir", { link = "Comment" })
    end
    set_picker_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = set_picker_highlights,
    })
  end,
  keys = {
    {
      "<leader>ee",
      function()
        Snacks.explorer()
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
          Snacks.explorer.reveal()
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
