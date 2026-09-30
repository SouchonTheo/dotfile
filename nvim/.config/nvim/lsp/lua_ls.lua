return {
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
          "MiniStarter", "MiniClue", "MiniExtra", "MiniSessions",
          "MiniVisits", "MiniDiff", "MiniGit",
        },
      },
      telemetry = { enable = false },
      hint = { enable = true },
    },
  },
}
