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

return {
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
}
