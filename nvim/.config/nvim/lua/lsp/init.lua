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
local missing = {} ---@type table<string, { bin: string, filetypes: string[] }>
for _, name in ipairs(servers) do
  local cfg = vim.lsp.config[name]
  local bin = cfg and cfg.cmd and cfg.cmd[1]
  if bin and vim.fn.executable(bin) == 1 then
    vim.lsp.enable(name)
  elseif name == "copilot" then
    -- Copilot covers every filetype: warn at startup
    vim.schedule(function()
      vim.notify(
        "Copilot: `copilot-language-server` not in PATH, ghost text disabled.\n"
          .. "npm i -g @github/copilot-language-server  (then restart nvim)",
        vim.log.levels.WARN
      )
    end)
  elseif bin then
    missing[name] = { bin = bin, filetypes = cfg.filetypes or {} }
  end
end

-- per-language servers: warn only when a file of that language is opened,
-- once per server and session (no noise for languages never touched here)
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_lsp_missing", { clear = true }),
  callback = function(ev)
    for name, info in pairs(missing) do
      if vim.tbl_contains(info.filetypes, ev.match) then
        missing[name] = nil
        vim.notify(("LSP %s: `%s` not in PATH, no LSP for %s files"):format(name, info.bin, ev.match), vim.log.levels.WARN)
      end
    end
  end,
})

require("lsp.attach")
