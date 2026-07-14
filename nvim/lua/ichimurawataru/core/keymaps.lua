vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

-- window management
local directions = {
  h = { axis = 2, cross = 1, step = -1, direction = "h" },
  j = { axis = 1, cross = 2, step = 1, direction = "j", no_wrap = true },
  k = { axis = 1, cross = 2, step = -1, direction = "k", no_wrap = true },
  l = { axis = 2, cross = 1, step = 1, direction = "l" },
}

local function window_center(win, axis)
  local position = vim.api.nvim_win_get_position(win)[axis]
  local size = axis == 1 and vim.api.nvim_win_get_height(win) or vim.api.nvim_win_get_width(win)
  return position + size / 2
end

local function is_navigable_window(win)
  local config = vim.api.nvim_win_get_config(win)
  local filetype = vim.bo[vim.api.nvim_win_get_buf(win)].filetype
  return (config.relative == "" or filetype == "snacks_picker_list")
    and filetype ~= "snacks_picker_input"
    and filetype ~= "snacks_layout_box"
end

local function navigate_window(rule)
  return function()
    if vim.fn.mode():sub(1, 1) == "i" then
      vim.cmd.stopinsert()
    end

    local current = vim.api.nvim_get_current_win()
    local current_position = vim.api.nvim_win_get_position(current)[rule.axis]

    if rule.no_wrap then
      vim.cmd("wincmd " .. rule.direction)
      return
    end

    -- For horizontal movement, choose by screen position so wrapped movement
    -- from sidebars continues to the adjacent editor pane instead of history.
    local windows = vim.tbl_filter(is_navigable_window, vim.api.nvim_tabpage_list_wins(0))

    local edge
    for _, win in ipairs(windows) do
      local position = vim.api.nvim_win_get_position(win)[rule.axis]
      local is_ahead = rule.step * (position - current_position) > 0
      if is_ahead then
        if edge == nil then
          edge = position
        elseif rule.step == 1 then
          edge = math.min(edge, position)
        else
          edge = math.max(edge, position)
        end
      end
    end

    if edge == nil then
      for _, win in ipairs(windows) do
        local position = vim.api.nvim_win_get_position(win)[rule.axis]
        if edge == nil then
          edge = position
        elseif rule.step == 1 then
          edge = math.min(edge, position)
        else
          edge = math.max(edge, position)
        end
      end
    end

    local target
    local distance
    local cross = window_center(current, rule.cross)
    for _, win in ipairs(windows) do
      if vim.api.nvim_win_get_position(win)[rule.axis] == edge then
        local candidate_distance = math.abs(window_center(win, rule.cross) - cross)
        if distance == nil or candidate_distance < distance then
          target = win
          distance = candidate_distance
        end
      end
    end

    if target then
      vim.api.nvim_set_current_win(target)
    end
  end
end

for direction, rule in pairs(directions) do
  keymap.set(
    { "n", "i" },
    "<C-" .. direction .. ">",
    navigate_window(rule),
    { desc = "Move to " .. direction .. " window with wrap" }
  )
end
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window
keymap.set("n", "<leader>>", "<cmd>vertical resize +5<CR>", { desc = "Widen current window" })
keymap.set("n", "<leader><", "<cmd>vertical resize -5<CR>", { desc = "Narrow current window" })

keymap.set("n", "<leader>to", function()
  local file = vim.api.nvim_buf_get_name(0)

  if file ~= "" then
    vim.cmd("tabnew " .. vim.fn.fnameescape(file))
    Snacks.explorer.reveal()
  else
    vim.cmd("tabnew")
  end
end, { desc = "Open new tab (focus file in tree)" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })

-- terminal
keymap.set("t", "<C-n>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
keymap.set("t", "<S-Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- claude code
keymap.set("n", "<leader>cc", function()
  local width = math.floor(vim.o.columns * 0.35)
  vim.cmd("vsplit")
  vim.cmd("vertical resize " .. width)
  vim.cmd("terminal claude --dangerously-skip-permissions")
  vim.cmd("startinsert")
end, { desc = "Open Claude Code (dangerously skip permissions)" })

-- smart home: first non-blank char, toggle to col 0 if already there
keymap.set("n", "<Home>", function()
  local col = vim.fn.col(".")
  local first_non_blank = vim.fn.match(vim.fn.getline("."), "\\S") + 1
  return col == first_non_blank and "0" or "^"
end, { expr = true, desc = "Smart home" })

keymap.set("i", "<Home>", function()
  local col = vim.fn.col(".")
  local first_non_blank = vim.fn.match(vim.fn.getline("."), "\\S") + 1
  return col == first_non_blank and "<C-o>0" or "<C-o>^"
end, { expr = true, desc = "Smart home" })

-- clear search highlight
keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- copy absolute file path to clipboard
keymap.set("n", "<leader>yp", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path, vim.log.levels.INFO)
end, { desc = "Copy absolute path" })
