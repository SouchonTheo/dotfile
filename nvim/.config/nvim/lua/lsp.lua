-- Native vim.lsp.config() / vim.lsp.enable() (nvim 0.11+).
-- Rust LSP is handled by rustaceanvim, NOT enabled here.

vim.lsp.config("clangd", {
  cmd = { "clangd", "--background-index", "--clang-tidy" },
  filetypes = { "c", "cpp", "objc", "objcpp" },
  root_markers = { ".clangd", "compile_commands.json", "compile_flags.txt", "Makefile", ".git" },
})

vim.lsp.config("zls", {
  cmd = { "zls" },
  filetypes = { "zig", "zir" },
  root_markers = { "zls.json", "build.zig", ".git" },
})

vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".stylua.toml", "stylua.toml", ".git" },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = { checkThirdParty = false },
      -- lazydev handles `vim` (it injects $VIMRUNTIME into workspace.library),
      -- but the Mini* globals are created at runtime by each module's setup()
      -- and have no type defs anywhere: declare them or every use warns.
      diagnostics = {
        globals = {
          "vim",
          "MiniIcons", "MiniMisc", "MiniPick", "MiniFiles", "MiniTrailspace",
          "MiniAnimate", "MiniStarter", "MiniSnippets", "MiniClue", "MiniExtra", "MiniSessions",
          "MiniVisits", "MiniDiff",
        },
      },
      telemetry = { enable = false },
      hint = { enable = true },
    },
  },
})

vim.lsp.config("taplo", {
  cmd = { "taplo", "lsp", "stdio" },
  filetypes = { "toml" },
  root_markers = { "taplo.toml", ".taplo.toml", ".git" },
})

-- JSON: pnpm add -g vscode-langservers-extracted. Formatting comes from the server
-- (provideFormatter) and conform falls back to it when prettier is not installed.
-- Schemas: SchemaStore matches by file name (package.json, tsconfig.json,
-- .vscode/settings.json, .github/workflows/*.yml, ...), giving completion + validation.
local ok_store, schemastore = pcall(require, "schemastore")
vim.lsp.config("jsonls", {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  root_markers = { ".git" },
  init_options = { provideFormatter = true },
  settings = {
    json = {
      schemas = ok_store and schemastore.json.schemas() or {},
      validate = { enable = true },
    },
  },
})

vim.lsp.config("yamlls", {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml", "yaml.docker-compose" },
  root_markers = { ".git" },
  settings = {
    yaml = {
      schemaStore = { enable = false, url = "" }, -- SchemaStore.nvim provides the list instead
      schemas = ok_store and schemastore.yaml.schemas() or {},
    },
  },
})

-- bashls shells out to shellcheck for diagnostics, install both to get them
vim.lsp.config("bashls", {
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh", "bash" },
  root_markers = { ".git" },
})

vim.lsp.config("marksman", {
  cmd = { "marksman", "server" },
  filetypes = { "markdown", "markdown.mdx" },
  root_markers = { ".marksman.toml", ".git" },
})

-- GitHub Copilot through the official language server + nvim 0.12 native
-- inline completion (no copilot.lua). Auth is shared with copilot.lua:
-- ~/.config/github-copilot/apps.json. :LspCopilotSignIn / :LspCopilotSignOut
-- exist if it ever needs to be redone. Install: npm i -g @github/copilot-language-server
-- PATH first, then the usual global-install dirs (pnpm add -g / npm i -g), so it
-- also works when nvim is started from the launcher with the bare session PATH.
local copilot_bin = (function()
  if vim.fn.executable("copilot-language-server") == 1 then return "copilot-language-server" end
  local pnpm = vim.env.PNPM_HOME or vim.fn.expand("~/.local/share/pnpm")
  local candidates = {
    vim.fn.expand("~/.local/bin/copilot-language-server"),
    pnpm .. "/copilot-language-server",
    vim.fn.expand("~/.npm-global/bin/copilot-language-server"),
    "/usr/local/bin/copilot-language-server",
  }
  -- The npm package ships a broken `bin` ("../dist/language-server.js", outside the
  -- package), so pnpm/npm create no shim. The standalone native binary lives in the
  -- platform package inside pnpm's store: pick it straight from there.
  vim.list_extend(candidates, vim.fn.glob(
    pnpm .. "/global/*/node_modules/.pnpm/@github+copilot-language-server-linux-x64@*/node_modules/@github/copilot-language-server-linux-x64/copilot-language-server",
    true, true))
  for _, c in ipairs(candidates) do
    if c ~= "" and vim.fn.executable(c) == 1 then return c end
  end
  return "copilot-language-server"
end)()

vim.lsp.config("copilot", {
  cmd = { copilot_bin, "--stdio" },
  root_markers = { ".git" },
  init_options = {
    editorInfo = { name = "Neovim", version = tostring(vim.version()) },
    editorPluginInfo = { name = "Neovim", version = tostring(vim.version()) },
  },
  settings = { telemetry = { telemetryLevel = "off" } },
  on_attach = function(client, bufnr)
    local function request(method, done)
      client:request(method, vim.empty_dict(), function(err, result)
        if err then return vim.notify(err.message, vim.log.levels.ERROR) end
        done(result)
      end)
    end
    vim.api.nvim_buf_create_user_command(bufnr, "LspCopilotSignIn", function()
      request("signIn", function(result)
        if result.status == "AlreadySignedIn" then
          return vim.notify("Copilot: already signed in as " .. result.user)
        end
        if result.command then
          vim.fn.setreg("+", result.userCode)
          vim.notify("Copilot: code " .. result.userCode .. " copied, opening " .. result.verificationUri)
          client:exec_cmd(result.command, { bufnr = bufnr }, function(cmd_err, cmd_result)
            if cmd_err then return vim.notify(cmd_err.message, vim.log.levels.ERROR) end
            if cmd_result and cmd_result.status == "OK" then vim.notify("Copilot: signed in as " .. cmd_result.user) end
          end)
        end
      end)
    end, { desc = "Copilot: sign in" })
    vim.api.nvim_buf_create_user_command(bufnr, "LspCopilotSignOut", function()
      request("signOut", function() vim.notify("Copilot: signed out") end)
    end, { desc = "Copilot: sign out" })
  end,
})

local ok, blink = pcall(require, "blink.cmp")
if ok then
  vim.lsp.config("*", { capabilities = blink.get_lsp_capabilities() })
end

-- enable each server only if its binary is installed
local servers = { "clangd", "zls", "lua_ls", "taplo", "jsonls", "yamlls", "bashls", "marksman", "copilot" }
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

-- nvim 0.11+ already provides grn (rename), grr (references), gra (code action),
-- gri (implementation), grt (type def), K (hover), gO (symbols).
-- Only what's missing, or what we prefer aliased to leader, is added here.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
    end

    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end

    -- Copilot ghost text. <Tab> accepts (wired in blink's keymap, setup/coding.lua),
    -- <M-]> / <M-[> cycle candidates, <leader>tc toggles (keymaps.lua).
    if client and client:supports_method("textDocument/inlineCompletion") then
      vim.lsp.inline_completion.enable(true, { bufnr = ev.buf })
      map("i", "<M-]>", function() vim.lsp.inline_completion.select({ count = 1 }) end, "Copilot: next suggestion")
      map("i", "<M-[>", function() vim.lsp.inline_completion.select({ count = -1 }) end, "Copilot: prev suggestion")
    end

    map("n", "gd", vim.lsp.buf.definition, "LSP: definition")
    map("n", "gD", vim.lsp.buf.declaration, "LSP: declaration")
    -- through conform (same formatters as format-on-save), LSP as fallback
    map("n", "<leader>cf", function() require("conform").format({ async = true, lsp_format = "fallback" }) end, "Format")
    map("n", "<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
    map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic")
    map("n", "]d", function() vim.diagnostic.jump({ count = 1,  float = true }) end, "Next diagnostic")
    map("n", "[e", function()
      vim.diagnostic.jump({ count = -1, float = true, severity = vim.diagnostic.severity.ERROR })
    end, "Prev error")
    map("n", "]e", function()
      vim.diagnostic.jump({ count = 1,  float = true, severity = vim.diagnostic.severity.ERROR })
    end, "Next error")
    map("n", "[w", function()
      vim.diagnostic.jump({ count = -1, float = true, severity = vim.diagnostic.severity.WARN })
    end, "Prev warning")
    map("n", "]w", function()
      vim.diagnostic.jump({ count = 1,  float = true, severity = vim.diagnostic.severity.WARN })
    end, "Next warning")
  end,
})
