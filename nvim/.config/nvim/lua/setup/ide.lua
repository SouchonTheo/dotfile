-- IMPORTANT: this file must be required BEFORE lua/lsp/, because
-- codesettings registers a global vim.lsp.config("*", before_init=...) hook
-- that needs to be in place before per-server configs are declared.

require("lazydev").setup({
  library = {
    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
  },
})

require("codesettings").setup({})
-- inject the local .vscode/settings.json into every LSP config
vim.lsp.config("*", {
  before_init = function(_, config)
    require("codesettings").with_local_settings(config.name, config)
  end,
})

-- rustaceanvim configures itself via vim.g (don't call setup()).
-- rust-analyzer settings live in lsp/rust-analyzer.lua with the other servers.
vim.g.rustaceanvim = {
  -- :RustLsp testables (<leader>ct) runs through neotest: summary + output
  -- panels instead of a raw terminal. cargo-nextest is picked up automatically.
  tools = { test_executor = "neotest" },
}

-- crates.nvim runs an in-process LSP on Cargo.toml buffers: blink completes
-- crate names/versions/features through the "lsp" source, gra gives its actions.
require("crates").setup({
  lsp = { enabled = true, actions = true, completion = true, hover = true },
  completion = { crates = { enabled = true } }, -- crates.io name search
})

require("neotest").setup({
  adapters = {
    require("rustaceanvim.neotest"),
  },
})

-- rustaceanvim auto-registers the rust codelldb adapter, so no manual
-- dap.adapters/configurations here. This only wires dap-ui to open and close
-- around a session, plus the signs.
local dap, dapui = require("dap"), require("dapui")
dapui.setup()
dap.listeners.before.attach.dapui_config       = function() dapui.open() end
dap.listeners.before.launch.dapui_config        = function() dapui.open() end
dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
dap.listeners.before.event_exited.dapui_config     = function() dapui.close() end

vim.fn.sign_define("DapBreakpoint",     { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped",        { text = "▶", texthl = "DiagnosticWarn",  linehl = "Visual", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticError", linehl = "", numhl = "" })
