-- Started by rustaceanvim, NOT by vim.lsp.enable (keep it out of the list in
-- lua/lsp/init.lua or two clients attach). rustaceanvim reads
-- vim.lsp.config["rust-analyzer"] at start and merges it over vim.g.rustaceanvim.server.
-- Plugin-side options (tools, dap) stay in lua/setup/ide.lua.
return {
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = false,
        targetDir = "target/analyzer",
        -- keep build scripts ON: disabling them makes rust-analyzer report
        -- phantom errors in any crate that generates code from build.rs
        -- (prost, tonic, bindgen). Costs one build up front, saves false positives.
        buildScripts = { enable = true },
      },
      -- lint with clippy on save instead of plain `cargo check`
      checkOnSave = true,
      check = { command = "clippy" },
    },
  },
}
