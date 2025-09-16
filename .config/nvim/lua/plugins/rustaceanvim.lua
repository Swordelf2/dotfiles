return {
  {
    "mrcjkb/rustaceanvim",
    opts = {
      server = {
        default_settings = {
          ["rust-analyzer"] = {
            check = { command = "clippy" },
            references = {
              excludeTests = true,
              excludeImports = true,
            },
            workspace = { symbol = { search = { kind = "all_symbols" } } }, -- rust-analyzer.workspace.symbol.search.kind
          },
        },
      },
    },
  },
}
