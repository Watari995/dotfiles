return {
  cmd = { "dart", "language-server", "--protocol=lsp" },
  filetypes = { "dart" },
  root_markers = { "pubspec.yaml" },
  settings = {
    dart = {
      completeFunctionCalls = true,
      showTodos = true,
    },
  },
}
