if not vim.g.vscode then
  return {}
end

local vscode = require("vscode")
local keymap = vim.keymap

-- ── ファイルツリー (Snacks Explorer → VSCode Explorer) ───────────────
keymap.set("n", "<leader>ee", function()
  vscode.eval([[
    (async () => {
      if (!globalThis.__nvimExplorerOpen) {
        globalThis.__nvimExplorerOpen = true;
        await vscode.commands.executeCommand('workbench.view.explorer');
      } else {
        globalThis.__nvimExplorerOpen = false;
        await vscode.commands.executeCommand('workbench.action.closeSidebar');
      }
    })()
  ]])
end, { desc = "Toggle file explorer" })
keymap.set("n", "<leader>ef", function() vscode.action("workbench.files.action.showActiveFileInExplorer") end, { desc = "Show file in explorer" })
keymap.set("n", "<leader>er", function() vscode.action("workbench.files.action.refreshFilesExplorer") end, { desc = "Refresh file explorer" })

-- ── ファイル検索 (Snacks Picker → VSCode Quick Open) ─────────────────
keymap.set("n", "<leader>ff", function() vscode.action("workbench.action.quickOpen") end, { desc = "Find files" })
keymap.set("n", "<leader>fs", function() vscode.action("workbench.action.findInFiles") end, { desc = "Find string in cwd" })
keymap.set("n", "<leader>fc", function() vscode.action("workbench.action.findInFiles") end, { desc = "Find string under cursor" })
keymap.set("n", "<leader>fr", function() vscode.action("workbench.action.openRecent") end, { desc = "Recent files" })
keymap.set("n", "<leader>fk", function() vscode.action("workbench.action.openGlobalKeybindings") end, { desc = "Find keymaps" })

-- ── LSP (Neovim LSP → VSCode LSP) ────────────────────────────────────
keymap.set("n", "gd", function() vscode.action("editor.action.revealDefinition") end, { desc = "Go to definition" })
keymap.set("n", "gD", function() vscode.action("editor.action.revealDeclaration") end, { desc = "Go to declaration" })
keymap.set("n", "gr", function() vscode.action("editor.action.goToReferences") end, { desc = "Go to references" })
keymap.set("n", "gi", function() vscode.action("editor.action.goToImplementation") end, { desc = "Go to implementation" })
keymap.set("n", "K",  function() vscode.action("editor.action.showHover") end, { desc = "Show hover" })
keymap.set("n", "<leader>ca", function() vscode.action("editor.action.quickFix") end, { desc = "Code action" })
keymap.set("n", "<leader>rn", function() vscode.action("editor.action.rename") end, { desc = "Rename" })
keymap.set("n", "<leader>D",  function() vscode.action("editor.action.goToTypeDefinition") end, { desc = "Go to type definition" })
keymap.set("n", "[d", function() vscode.action("editor.action.marker.prevInFiles") end, { desc = "Prev diagnostic" })
keymap.set("n", "]d", function() vscode.action("editor.action.marker.nextInFiles") end, { desc = "Next diagnostic" })

-- ── Diagnostics (Trouble → VSCode Problems) ──────────────────────────
keymap.set("n", "<leader>xw", function() vscode.action("workbench.actions.view.problems") end, { desc = "Workspace diagnostics" })
keymap.set("n", "<leader>xd", function() vscode.action("workbench.actions.view.problems") end, { desc = "Document diagnostics" })

-- ── Git (LazyGit → VSCode SCM) ───────────────────────────────────────
keymap.set("n", "<leader>lg", function() vscode.action("lazygit-vscode.toggle") end, { desc = "Toggle LazyGit" })

-- ── Git hunks (gitsigns → VSCode diff) ───────────────────────────────
keymap.set("n", "]h", function() vscode.action("workbench.action.editor.nextChange") end, { desc = "Next hunk" })
keymap.set("n", "[h", function() vscode.action("workbench.action.editor.previousChange") end, { desc = "Prev hunk" })
keymap.set("n", "<leader>hp", function() vscode.action("editor.action.dirtydiff.next") end, { desc = "Preview hunk" })
keymap.set("n", "<leader>hs", function() vscode.action("git.stageSelectedRanges") end, { desc = "Stage hunk" })
keymap.set("n", "<leader>hr", function() vscode.action("git.revertSelectedRanges") end, { desc = "Reset hunk" })

-- ── ウィンドウ移動 (Ctrl+hjkl → editor group navigation) ────────────
keymap.set("n", "<C-h>", function() vscode.action("workbench.action.navigateLeft") end, { desc = "Move to left editor group" })
keymap.set("n", "<C-j>", function() vscode.action("workbench.action.navigateDown") end, { desc = "Move to lower editor group" })
keymap.set("n", "<C-k>", function() vscode.action("workbench.action.navigateUp") end, { desc = "Move to upper editor group" })
keymap.set("n", "<C-l>", function() vscode.action("workbench.action.navigateRight") end, { desc = "Move to right editor group" })

-- ── ウィンドウ分割 (splits → VSCode editor groups) ───────────────────
keymap.set("n", "<leader>sv", function() vscode.action("workbench.action.splitEditorRight") end, { desc = "Split right" })
keymap.set("n", "<leader>sh", function() vscode.action("workbench.action.splitEditorDown") end, { desc = "Split down" })
keymap.set("n", "<leader>se", function() vscode.action("workbench.action.evenEditorWidths") end, { desc = "Equal splits" })
keymap.set("n", "<leader>sx", function() vscode.action("workbench.action.closeEditorsAndGroup") end, { desc = "Close split" })
keymap.set("n", "<leader>sm", function() vscode.action("workbench.action.toggleMaximizeEditorGroup") end, { desc = "Maximize/minimize split" })

-- ── タブ (bufferline → VSCode tabs) ──────────────────────────────────
keymap.set("n", "<leader>tn", function() vscode.action("workbench.action.nextEditor") end, { desc = "Next tab" })
keymap.set("n", "<leader>tp", function() vscode.action("workbench.action.previousEditor") end, { desc = "Prev tab" })
keymap.set("n", "<leader>tx", function() vscode.action("workbench.action.closeActiveEditor") end, { desc = "Close tab" })
keymap.set("n", "<leader>to", function() vscode.action("workbench.action.files.newUntitledFile") end, { desc = "New tab" })

-- ── ターミナル (<leader>cc → Claude Code with dangerously-skip-permissions) ──
keymap.set("n", "<leader>cc", function()
  vscode.action("workbench.action.terminal.new")
  vim.defer_fn(function()
    vscode.action("workbench.action.terminal.sendSequence", {
      args = { text = "claude --dangerously-skip-permissions\r" },
    })
  end, 300)
end, { desc = "Open Claude Code" })

-- ── フォーマット ──────────────────────────────────────────────────────
keymap.set("n", "<leader>mp", function() vscode.action("editor.action.formatDocument") end, { desc = "Format document" })

return {}
