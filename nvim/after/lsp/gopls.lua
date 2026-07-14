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
