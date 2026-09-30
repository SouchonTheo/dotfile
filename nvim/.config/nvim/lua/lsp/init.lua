-- Native vim.lsp.config() / vim.lsp.enable() (nvim 0.11+).
-- Each server's config lives in lsp/<name>.lua at the config root: nvim merges
-- those files into vim.lsp.config[<name>] by itself (:h lsp-config).
-- rust-analyzer: config in lsp/rust-analyzer.lua, but started by rustaceanvim,
-- so it must NOT be in the list below.

local ok, blink = pcall(require, "blink.cmp")
if ok then
  vim.lsp.config("*", { capabilities = blink.get_lsp_capabilities() })
end

-- enable each server only if its binary is installed
local servers = { "clangd", "zls", "lua_ls", "taplo", "ts_ls", "jsonls", "yamlls", "bashls", "marksman", "copilot" }
for _, name in ipairs(servers) do
  local cfg = vim.lsp.config[name]
  local bin = cfg and cfg.cmd and cfg.cmd[1]
  if bin and vim.fn.executable(bin) == 1 then
    vim.lsp.enable(name)
  elseif name == "copilot" then
    -- the others are optional per-language servers; Copilot missing is worth a heads-up
    vim.schedule(function()
      vim.notify(
        "Copilot: `copilot-language-server` not in PATH, ghost text disabled.\n"
          .. "npm i -g @github/copilot-language-server  (then restart nvim)",
        vim.log.levels.WARN
      )
    end)
  end
end

require("lsp.attach")
