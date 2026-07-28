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
      -- CI covers staticcheck; disabling it keeps gopls more responsive in large Go monorepos.
      staticcheck = false,
      gofumpt = true,
      usePlaceholders = false,
      completeUnimported = true,
      completionDocumentation = false,
      deepCompletion = false,
      hoverKind = "SynopsisDocumentation",
      linkTarget = "pkg.go.dev",
      diagnosticsDelay = "1s",
      semanticTokens = false,
      buildFlags = {
        "-tags=parallel,serial,integration,integration_parallel,parallel_test",
      },
      directoryFilters = {
        "-node_modules",
        "-**/node_modules",
        "-vendor",
        "-**/vendor",
        "-testdata",
        "-**/testdata",
        "-frontend",
        "-.claude",
        "-.cursor",
        "-.github",
        "-.husky",
        "-.kiro",
        "-.serena",
        "-.vscode",
        "-fixtures",
        "-**/fixtures",
        -- Exclude auxiliary Go modules that are not part of day-to-day app navigation.
        "-linter_modules",
        "-load-tests",
        "-migrations",
        "-protobuf",
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
