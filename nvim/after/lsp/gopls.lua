return {
  capabilities = {
    textDocument = {
      completion = {
        completionItem = {
          snippetSupport = false,
        },
      },
    },
  },
  settings = {
    gopls = {
      staticcheck = true,
      gofumpt = true,
      usePlaceholders = false,
      completeUnimported = true,
      hoverKind = "SynopsisDocumentation",
      linkTarget = "pkg.go.dev",
      buildFlags = {
        "-tags=parallel,serial,integration,integration_parallel,parallel_test",
      },
      directoryFilters = {
        "-node_modules",
        "-vendor",
        "-testdata",
        "-frontend",
        "-.claude",
        "-.cursor",
        "-.github",
        "-.husky",
        "-.kiro",
        "-.serena",
        "-.vscode",
        "-fixtures",
        "-load-tests",
        "-migrations",
        "-public",
      },
      analyses = {
        ST1003 = false,
        nilness = true,
        unusedparams = true,
        unusedwrite = true,
        useany = true,
      },
    },
  },
}
