vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew %<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

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
